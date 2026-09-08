import { filterMenuItemsByFeatures } from "c/pwchronoNavigationAccess";
import { normalizeApplicationRoute } from "c/pwchronoRouter";

const MENU_ITEMS = [
  { id: "dashboard", label: "Dashboard", children: [] },
  { id: "profile", label: "My Profile", children: [] },
  { id: "payroll", label: "Payroll", children: [] },
  {
    id: "administration",
    label: "Administration",
    children: [
      { id: "reports", label: "Reports Dashboard", children: [] },
      { id: "role-map", label: "Role Feature Mapping", children: [] }
    ]
  },
  {
    id: "unmapped-parent",
    label: "Unmapped Parent",
    children: [{ id: "attendance", label: "Attendance Employee", children: [] }]
  },
  { id: "unknown", label: "Unknown Item", children: [] }
];

describe("pwchronoNavigationAccess", () => {
  it("shows only items allowed by the employee feature set", () => {
    const result = filterMenuItemsByFeatures(MENU_ITEMS, [
      "Dashboard",
      "My Profile"
    ]);

    expect(result.map((item) => item.id)).toEqual(["dashboard", "profile"]);
  });

  it("retains a parent when at least one child is visible", () => {
    const result = filterMenuItemsByFeatures(MENU_ITEMS, [
      "Attendance Management"
    ]);

    expect(result).toEqual([
      {
        id: "unmapped-parent",
        label: "Unmapped Parent",
        children: [
          { id: "attendance", label: "Attendance Employee", children: [] }
        ]
      }
    ]);
  });

  it("returns the complete menu when every required feature is assigned", () => {
    expect(
      filterMenuItemsByFeatures(MENU_ITEMS, [
        "Dashboard",
        "My Profile",
        "Payroll",
        "Admin Settings",
        "Reports Dashboard",
        "Attendance Management"
      ])
    ).toEqual(MENU_ITEMS.slice(0, -1));
  });

  it("hides unmapped leaf items", () => {
    expect(
      filterMenuItemsByFeatures(
        [{ id: "unknown", label: "Unknown Item", children: [] }],
        ["Dashboard"]
      )
    ).toEqual([]);
  });

  it("does not expose admin attendance to an employee", () => {
    const items = [
      {
        id: "attendance-parent",
        label: "Attendance Management",
        children: [
          { id: "employee", label: "Attendance Employee", children: [] },
          { id: "admin", label: "Attendance (Admin)", children: [] }
        ]
      }
    ];

    expect(filterMenuItemsByFeatures(items, ["Attendance Management"])).toEqual(
      [
        {
          id: "attendance-parent",
          label: "Attendance Management",
          children: [
            { id: "employee", label: "Attendance Employee", children: [] }
          ]
        }
      ]
    );
  });

  it("exposes scoped attendance without attendance settings to managers", () => {
    const items = [
      { id: "admin", label: "Attendance (Admin)", children: [] },
      { id: "settings", label: "Attendance Settings", children: [] }
    ];

    expect(filterMenuItemsByFeatures(items, ["Attendance Team"])).toEqual([
      { id: "admin", label: "Attendance (Admin)", children: [] }
    ]);
  });
});

describe("PWChrono application routes", () => {
  it("normalizes application menu aliases", () => {
    expect(normalizeApplicationRoute("Employee Directory")).toBe("directory");
    expect(normalizeApplicationRoute("Project List")).toBe("projects");
    expect(normalizeApplicationRoute("Company Policies")).toBe("policies");
    expect(normalizeApplicationRoute("Reports Dashboard")).toBe("reports");
  });

  it("falls back safely for unknown routes", () => {
    expect(normalizeApplicationRoute("not-a-real-module")).toBe("dashboard");
    expect(normalizeApplicationRoute(null)).toBe("dashboard");
  });
});
