/**
 * Fork extension: unbounded analysis mode.
 *
 * `REA_UNBOUNDED=1` (also `true` or `yes`) lifts default analysis deadlines and
 * fixed byte, entry and record budgets so complete breakdowns of very large
 * targets run to completion instead of stopping at a timer or a size ceiling.
 * Host memory, disk space and file-format limits still apply, as do limits
 * imposed by the JavaScript engine itself.
 *
 * Unset, REA keeps its upstream bounded defaults, so existing behavior and
 * tests are unchanged.
 */
const parseFlag = (value: string | undefined): boolean => {
  const normalized = value?.trim().toLowerCase();
  return normalized === "1" || normalized === "true" || normalized === "yes";
};

/** Read once at module load; child processes inherit the same environment. */
export const UNBOUNDED_MODE: boolean = parseFlag(process.env.REA_UNBOUNDED);

/** Largest delay Node.js timers accept (about 24.8 days): no practical deadline. */
export const UNBOUNDED_TIMEOUT_MS = 2_147_483_647;

/** A fixed byte, entry or record budget. Unlimited in unbounded mode. */
export const sizeBudget = (bounded: number): number =>
  UNBOUNDED_MODE ? Number.MAX_SAFE_INTEGER : bounded;

/** A caller-facing maximum for a budget parameter. Unlimited in unbounded mode. */
export const sizeMaximum = (bounded: number): number =>
  UNBOUNDED_MODE ? Number.MAX_SAFE_INTEGER : bounded;

/** A default deadline. The maximum timer delay in unbounded mode. */
export const deadlineDefault = (bounded: number): number =>
  UNBOUNDED_MODE ? UNBOUNDED_TIMEOUT_MS : bounded;

/**
 * A default for a caller-selectable budget. In unbounded mode the default becomes
 * the supplied maximum, so omitting the option means "examine everything".
 */
export const budgetDefault = (bounded: number, maximum: number): number =>
  UNBOUNDED_MODE ? maximum : bounded;
