import { filterMenuItemsByFeatures } from "c/pwchronoNavigationAccess";

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
});
