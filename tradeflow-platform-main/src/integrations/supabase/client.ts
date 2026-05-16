/**
 * Supabase Compatibility Shim
 * Routes all Supabase-style calls to the new Prisma/Express REST API.
 * Maintains the same interface so existing components continue to work.
 */
import api from "@/lib/api";

// ─── Auth shim ───────────────────────────────────────────────────────────────

const authListeners: Array<(event: string, session: any) => void> = [];

const auth = {
  getSession: async () => {
    const token = localStorage.getItem("auth_token");
    if (!token) return { data: { session: null }, error: null };
    try {
      const { data } = await api.get("/auth/me");
      return {
        data: {
          session: {
            access_token: token,
            user: {
              id: data.user?.id,
              email: `${data.user?.username}@eternia.local`,
            },
          },
        },
        error: null,
      };
    } catch {
      return { data: { session: null }, error: null };
    }
  },

  getUser: async () => {
    const token = localStorage.getItem("auth_token");
    if (!token) return { data: { user: null }, error: null };
    try {
      const { data } = await api.get("/auth/me");
      return {
        data: {
          user: {
            id: data.user?.id,
            email: `${data.user?.username}@eternia.local`,
            user_metadata: data.user,
          },
        },
        error: null,
      };
    } catch {
      return { data: { user: null }, error: null };
    }
  },

  setSession: async (tokens: {
    access_token: string;
    refresh_token?: string;
  }) => {
    if (tokens.access_token)
      localStorage.setItem("auth_token", tokens.access_token);
    if (tokens.refresh_token)
      localStorage.setItem("refresh_token", tokens.refresh_token);
    return { data: {}, error: null };
  },

  signInWithPassword: async ({
    email,
    password,
  }: {
    email: string;
    password: string;
  }) => {
    const username = email
      .replace("@eternia.local", "")
      .replace("@eternia.com", "");
    try {
      const { data } = await api.post("/auth/login", { username, password });
      localStorage.setItem("auth_token", data.token);
      if (data.refreshToken)
        localStorage.setItem("refresh_token", data.refreshToken);
      return {
        data: {
          session: { access_token: data.token, user: { id: data.user.id } },
          user: data.user,
        },
        error: null,
      };
    } catch (err: any) {
      return {
        data: { session: null, user: null },
        error: { message: err.response?.data?.error || "Login failed" },
      };
    }
  },

  signUp: async ({ email, password, options }: any) => {
    const username = email
      .replace("@eternia.local", "")
      .replace("@eternia.com", "");
    try {
      const { data } = await api.post("/auth/register", {
        username,
        password,
        ...(options?.data || {}),
      });
      localStorage.setItem("auth_token", data.token);
      if (data.refreshToken)
        localStorage.setItem("refresh_token", data.refreshToken);
      return {
        data: { session: { access_token: data.token }, user: data.user },
        error: null,
      };
    } catch (err: any) {
      return {
        data: { session: null, user: null },
        error: { message: err.response?.data?.error || "Registration failed" },
      };
    }
  },

  signOut: async () => {
    try {
      await api.post("/auth/logout");
    } catch {}
    localStorage.removeItem("auth_token");
    localStorage.removeItem("refresh_token");
    return { error: null };
  },

  onAuthStateChange: (callback: (event: string, session: any) => void) => {
    authListeners.push(callback);
    // Fire initial state
    auth.getSession().then(({ data: { session } }) => {
      callback(session ? "SIGNED_IN" : "SIGNED_OUT", session);
    });
    return {
      data: {
        subscription: {
          unsubscribe: () => {
            const idx = authListeners.indexOf(callback);
            if (idx > -1) authListeners.splice(idx, 1);
          },
        },
      },
    };
  },
};

// ─── Table-to-endpoint mapping ────────────────────────────────────────────────

const TABLE_ENDPOINTS: Record<string, string> = {
  profiles: "/profiles",
  appointments: "/appointments",
  expert_availability: "/appointments/slots",
  credit_transactions: "/credits/transactions",
  peer_sessions: "/peers/sessions",
  peer_messages: "/peers/messages",
  blackbox_entries: "/blackbox/entries",
  blackbox_sessions: "/blackbox/sessions",
  notifications: "/notifications",
  institutions: "/institutions",
  quest_cards: "/quests",
  quest_completions: "/quests/completions/today",
  sound_content: "/sound",
  escalation_requests: "/admin/escalations",
  audit_logs: "/admin/audit-logs",
  recovery_credentials: "/profiles/recovery-check",
  user_private: "/profiles/private",
  gratitude_entries: "/selfhelp/gratitude",
  journal_entries: "/selfhelp/journal",
  mood_entries: "/selfhelp/mood",
  analytics_events: "/analytics/events",
  user_roles: "/profiles/roles",
  temp_credentials: "/auth/temp-credentials",
  institution_student_ids: "/profiles/student-ids",
};

// ─── Query Builder ────────────────────────────────────────────────────────────

type FilterOp = "eq" | "neq" | "gt" | "gte" | "lt" | "lte" | "in" | "contains";

interface QueryState {
  table: string;
  method: "select" | "insert" | "update" | "delete" | "upsert";
  fields: string;
  filters: Array<{ col: string; op: FilterOp; val: any }>;
  orderCol: string | null;
  orderAsc: boolean;
  limitN: number | null;
  singleResult: boolean;
  maybeSingleResult: boolean;
  body: any;
  headOnly: boolean;
  countOnly: boolean;
  rangeStart: number | null;
  rangeEnd: number | null;
}

function buildQueryString(filters: QueryState["filters"]): Record<string, any> {
  const params: Record<string, any> = {};
  for (const f of filters) {
    if (f.op === "eq") params[f.col] = f.val;
    else if (f.op === "in")
      params[`${f.col}__in`] = Array.isArray(f.val) ? f.val.join(",") : f.val;
    else params[`${f.col}__${f.op}`] = f.val;
  }
  return params;
}

function createQueryBuilder(state: QueryState): any {
  const execute = async (): Promise<{
    data: any;
    error: any;
    count?: number;
  }> => {
    const endpoint = TABLE_ENDPOINTS[state.table] || `/data/${state.table}`;

    try {
      if (state.method === "select") {
        const params: Record<string, any> = {
          ...buildQueryString(state.filters),
          fields: state.fields !== "*" ? state.fields : undefined,
        };
        if (state.orderCol) {
          params.order_by = state.orderCol;
          params.order_dir = state.orderAsc ? "asc" : "desc";
        }
        if (state.limitN) params.limit = state.limitN;

        if (state.headOnly && state.countOnly) {
          // Count-only query
          try {
            const { data } = await api.get(endpoint, {
              params: { ...params, count: true },
            });
            return {
              data: null,
              error: null,
              count: data.count ?? (Array.isArray(data) ? data.length : 0),
            };
          } catch {
            return { data: null, error: null, count: 0 };
          }
        }

        const { data: raw } = await api.get(endpoint, { params });

        // Normalize response
        let result: any = raw;
        if (raw && typeof raw === "object" && !Array.isArray(raw)) {
          // Pick the most likely array field
          const arrays = Object.values(raw).filter(Array.isArray);
          if (arrays.length === 1) result = arrays[0];
          else if (raw.data) result = raw.data;
          else if (raw.items) result = raw.items;
        }

        if (state.singleResult || state.maybeSingleResult) {
          const arr = Array.isArray(result) ? result : [result];
          const item = arr[0] ?? null;
          if (state.singleResult && !item) {
            return {
              data: null,
              error: { message: "Row not found", code: "PGRST116" },
            };
          }
          return { data: item, error: null };
        }

        return { data: Array.isArray(result) ? result : [result], error: null };
      } else if (state.method === "insert") {
        const payload = Array.isArray(state.body) ? state.body[0] : state.body;
        const { data: raw } = await api.post(endpoint, payload);
        const result = raw?.data ?? raw;
        if (state.singleResult || state.maybeSingleResult) {
          return {
            data: Array.isArray(result) ? result[0] : result,
            error: null,
          };
        }
        return { data: result, error: null };
      } else if (state.method === "update") {
        const idFilter = state.filters.find(
          (f) => f.col === "id" && f.op === "eq",
        );
        if (idFilter) {
          const { data: raw } = await api.patch(
            `${endpoint}/${idFilter.val}`,
            state.body,
          );
          return { data: raw?.data ?? raw, error: null };
        }
        // Bulk update via query params
        const params = buildQueryString(state.filters);
        const { data: raw } = await api.patch(endpoint, {
          ...state.body,
          _filters: params,
        });
        return { data: raw?.data ?? raw, error: null };
      } else if (state.method === "upsert") {
        const { data: raw } = await api.post(endpoint, state.body);
        return { data: raw?.data ?? raw, error: null };
      } else if (state.method === "delete") {
        const idFilter = state.filters.find(
          (f) => f.col === "id" && f.op === "eq",
        );
        if (idFilter) {
          await api.delete(`${endpoint}/${idFilter.val}`);
          return { data: null, error: null };
        }
        const params = buildQueryString(state.filters);
        await api.delete(endpoint, { params });
        return { data: null, error: null };
      }

      return { data: null, error: { message: "Unknown method" } };
    } catch (err: any) {
      console.error(
        `[SupabaseShim] ${state.method} ${state.table}:`,
        err.message,
      );
      return {
        data: null,
        error: { message: err.response?.data?.error || err.message },
      };
    }
  };

  const addFilter = (col: string, op: FilterOp, val: any) =>
    createQueryBuilder({
      ...state,
      filters: [...state.filters, { col, op, val }],
    });

  const builder: any = {
    // Awaitable
    then: (resolve: any, reject: any) => execute().then(resolve, reject),
    catch: (reject: any) => execute().catch(reject),

    // Filter methods
    eq: (col: string, val: any) => addFilter(col, "eq", val),
    neq: (col: string, val: any) => addFilter(col, "neq", val),
    gt: (col: string, val: any) => addFilter(col, "gt", val),
    gte: (col: string, val: any) => addFilter(col, "gte", val),
    lt: (col: string, val: any) => addFilter(col, "lt", val),
    lte: (col: string, val: any) => addFilter(col, "lte", val),
    in: (col: string, vals: any[]) => addFilter(col, "in", vals),
    contains: (col: string, val: any) => addFilter(col, "contains", val),
    not: (col: string, op: string, val: any) => addFilter(col, "neq", val),

    // Modifiers
    order: (col: string, opts?: { ascending?: boolean }) =>
      createQueryBuilder({
        ...state,
        orderCol: col,
        orderAsc: opts?.ascending !== false,
      }),
    limit: (n: number) => createQueryBuilder({ ...state, limitN: n }),
    range: (from: number, to: number) =>
      createQueryBuilder({ ...state, rangeStart: from, rangeEnd: to }),
    single: () => createQueryBuilder({ ...state, singleResult: true }),
    maybeSingle: () =>
      createQueryBuilder({ ...state, maybeSingleResult: true }),

    // Select for insert/update chains
    select: (fields = "*") => createQueryBuilder({ ...state, fields }),
  };

  return builder;
}

// ─── Functions shim ───────────────────────────────────────────────────────────

const FUNCTION_ENDPOINTS: Record<string, string> = {
  "activate-account": "/auth/activate-account",
  "add-member": "/admin/members",
  "admin-delete-institution": "/admin/institutions",
  "admin-delete-member": "/admin/members",
  "ai-moderate": "/blackbox/entries",
  "ai-transcribe": "/blackbox/transcribe",
  "approve-password-reset": "/auth/approve-password-reset",
  "bulk-add-members": "/admin/members/bulk",
  "claim-l3-session": "/blackbox/sessions/claim",
  "create-bulk-temp-ids": "/admin/temp-credentials/bulk",
  "escalate-emergency": "/peers/sessions/escalate",
  "generate-analytics-report": "/analytics/report",
  "generate-spoc-qr": "/profiles/spoc-qr",
  "get-emergency-contact": "/profiles/emergency-contact",
  "get-recovery-hints": "/auth/get-recovery-hints",
  "grant-credits": "/credits/grant",
  "indexnow-submit": "/admin/indexnow",
  "purchase-credits": "/credits/purchase/create-order",
  "recover-password": "/auth/recover-password",
  "refund-blackbox-session": "/blackbox/sessions/refund",
  "request-account-deletion": "/auth/request-deletion",
  "seed-admin": "/admin/seed",
  "spend-credits": "/credits/spend",
  "stability-pool-contribute": "/credits/stability-pool",
  "validate-spoc-qr": "/profiles/validate-spoc-qr",
  "verify-student-id": "/profiles/verify-student-id",
  "verify-temp-credentials": "/auth/verify-temp-credentials",
  "videosdk-token": "/videosdk/token",
};

const functions = {
  invoke: async (funcName: string, options?: { body?: any; headers?: any }) => {
    const endpoint = FUNCTION_ENDPOINTS[funcName];
    if (!endpoint) {
      console.warn(`[SupabaseShim] Unknown function: ${funcName}`);
      return {
        data: null,
        error: { message: `Function ${funcName} not mapped` },
      };
    }
    try {
      const { data } = await api.post(endpoint, options?.body || {});
      return { data, error: null };
    } catch (err: any) {
      return {
        data: null,
        error: { message: err.response?.data?.error || err.message },
      };
    }
  },
};

// ─── RPC shim ─────────────────────────────────────────────────────────────────

const RPC_ENDPOINTS: Record<
  string,
  { method: "get" | "post"; endpoint: string }
> = {
  get_credit_balance: { method: "get", endpoint: "/credits/balance" },
  get_credit_balance_fast: { method: "get", endpoint: "/credits/balance" },
  get_daily_earn_total: {
    method: "get",
    endpoint: "/credits/weekly-earn-total",
  },
  get_weekly_earn_total: {
    method: "get",
    endpoint: "/credits/weekly-earn-total",
  },
  get_blackbox_daily_count: {
    method: "get",
    endpoint: "/blackbox/daily-count",
  },
  get_blackbox_usage_count: {
    method: "get",
    endpoint: "/blackbox/usage-count",
  },
  spend_credits_atomic: { method: "post", endpoint: "/credits/spend" },
  check_rate_limit: { method: "post", endpoint: "/auth/rate-check" },
};

// ─── Channel/Realtime shim (polling-based) ────────────────────────────────────

function createChannel(name: string) {
  return {
    on: (_event: string, _opts: any, _callback?: Function) =>
      createChannel(name),
    subscribe: (callback?: Function) => {
      if (callback) callback("SUBSCRIBED");
      return createChannel(name);
    },
    unsubscribe: () => {},
  };
}

// ─── Main supabase shim object ────────────────────────────────────────────────

export const supabase = {
  auth,
  functions,

  from: (table: string) => {
    const makeState = (method: QueryState["method"]): QueryState => ({
      table,
      method,
      fields: "*",
      filters: [],
      orderCol: null,
      orderAsc: true,
      limitN: null,
      singleResult: false,
      maybeSingleResult: false,
      body: null,
      headOnly: false,
      countOnly: false,
      rangeStart: null,
      rangeEnd: null,
    });

    return {
      select: (fields = "*", opts?: { count?: string; head?: boolean }) => {
        const s = makeState("select");
        s.fields = fields;
        s.headOnly = opts?.head ?? false;
        s.countOnly = !!opts?.count;
        return createQueryBuilder(s);
      },
      insert: (body: any, opts?: any) => {
        const s = makeState("insert");
        s.body = body;
        return createQueryBuilder(s);
      },
      update: (body: any, opts?: any) => {
        const s = makeState("update");
        s.body = body;
        return createQueryBuilder(s);
      },
      upsert: (body: any, opts?: any) => {
        const s = makeState("upsert");
        s.body = body;
        return createQueryBuilder(s);
      },
      delete: () => createQueryBuilder(makeState("delete")),
    };
  },

  rpc: async (funcName: string, params?: any) => {
    const mapping = RPC_ENDPOINTS[funcName];
    if (!mapping) {
      console.warn(`[SupabaseShim] Unknown RPC: ${funcName}`);
      return { data: null, error: { message: `RPC ${funcName} not mapped` } };
    }
    try {
      let raw: any;
      if (mapping.method === "get") {
        const { data } = await api.get(mapping.endpoint);
        raw = data;
      } else {
        const body = params
          ? Object.fromEntries(
              Object.entries(params).map(([k, v]) => [k.replace(/^_/, ""), v]),
            )
          : {};
        const { data } = await api.post(mapping.endpoint, body);
        raw = data;
      }
      // Extract scalar value for balance/count RPCs
      const val = raw?.balance ?? raw?.total ?? raw?.count ?? raw;
      return { data: val, error: null };
    } catch (err: any) {
      return {
        data: null,
        error: { message: err.response?.data?.error || err.message },
      };
    }
  },

  channel: (name: string) => createChannel(name),
  removeChannel: (_channel: any) => {},
  removeAllChannels: () => {},
};

// Default export for compatibility
export default supabase;
