const MENU_FEATURE_MAP = {
  Dashboard: ["Dashboard"],
  "Admin Dashboard": ["Admin Settings", "Configuration"],
  "Manager Dashboard": ["Manager Dashboard"],
  "Employee Dashboard": ["Dashboard"],
  "My Profile": ["My Profile"],
  "Attendance Management": ["Attendance Management"],
  "Attendance Employee": ["Attendance Management"],
  "Attendance (Admin)": ["Attendance Team", "Attendance Administration"],
  Overtime: ["Attendance Management"],
  "WFH Management": ["Attendance Management"],
  Timesheets: ["Attendance Management"],
  "Attendance Settings": ["Attendance Administration"],
  "Leave Management": ["Leave Management"],
  "Leaves (Employee)": ["Leave Management"],
  "Leaves Admin": ["Leave Management"],
  "Leave Settings": ["Admin Settings", "Configuration"],
  Holidays: ["Holidays"],
  "Employee Directory": ["Employee Directory"],
  Recruitment: ["Recruitment"],
  Onboarding: ["Onboarding"],
  Performance: ["Performance Management", "Appraisal", "Goals"],
  Training: ["Training Management"],
  "Projects List": ["Projects", "Dashboard"],
  Projects: ["Projects", "Dashboard"],
  "Expense Management": ["Expense Management"],
  Payroll: ["Payroll"],
  Administration: ["Admin Settings", "Configuration"],
  "Reports Dashboard": ["Reports Dashboard", "Admin Settings", "Configuration"],
  "Role Feature Mapping": ["Admin Settings", "Configuration"]
};

function hasMenuAccess(item, featureSet) {
  const requiredFeatures = MENU_FEATURE_MAP[item?.label];
  return Boolean(requiredFeatures?.some((feature) => featureSet.has(feature)));
}

export function filterMenuItemsByFeatures(items, features) {
  const featureSet = new Set(features || []);
  return (items || []).reduce((visibleItems, item) => {
    const children = filterMenuItemsByFeatures(item.children || [], features);
    if (!hasMenuAccess(item, featureSet) && children.length === 0) {
      return visibleItems;
    }
    visibleItems.push({ ...item, children });
    return visibleItems;
  }, []);
}
