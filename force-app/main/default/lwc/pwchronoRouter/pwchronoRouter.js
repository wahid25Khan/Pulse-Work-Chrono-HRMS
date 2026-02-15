/**
 * Router utility for hash-based URL routing
 * Provides centralized navigation across the portal
 */

export function getCurrentPage() {
  const w = globalThis?.window ?? globalThis;
  return w?.location?.hash?.substring(1) || "dashboard";
}

export function navigateTo(page) {
  const w = globalThis?.window ?? globalThis;
  if (!w?.location) return;
  if (!page) {
    w.location.hash = "";
    return;
  }
  w.location.hash = `#${page}`;
}

export function isPageActive(page) {
  return getCurrentPage() === page;
}

export function onPageChange(callback) {
  // Call immediately with current page
  callback(getCurrentPage());

  // Listen for future changes
  const handler = () => {
    callback(getCurrentPage());
  };

  const w = globalThis?.window ?? globalThis;
  w?.addEventListener?.("hashchange", handler);

  // Return unsubscribe function
  return () => {
    w?.removeEventListener?.("hashchange", handler);
  };
}

// Page constants for consistency
export const PAGES = {
  DASHBOARD: "dashboard",
  LEAVE: "leave",
  ATTENDANCE: "attendance",
  PROFILE: "profile",
  CONFIGURATION: "configuration",
  MANAGER_DASHBOARD: "manager-dashboard",
  CHAT: "chat",
  PAYROLL: "payroll",
  RECRUITMENT: "recruitment",
  PERFORMANCE: "performance",
  TRAINING: "training"
};