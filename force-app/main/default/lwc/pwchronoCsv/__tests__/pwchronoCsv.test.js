import { toCsv } from "c/pwchronoCsv";
describe("CSV export", () => {
  it("quotes commas, quotes and line breaks", () => {
    expect(toCsv(["Name"], [['A, "B"\nC']])).toBe('"Name"\r\n"A, ""B""\nC"');
  });
  it("neutralizes spreadsheet formulas", () => {
    expect(toCsv(["Value"], [["=1+1"], [" +cmd"], ["@SUM(A1)"]])).toContain(
      '"\'=1+1"'
    );
  });
  it("preserves zero and represents missing values as empty cells", () => {
    expect(toCsv(["A", "B"], [[0, null]])).toBe('"A","B"\r\n"0",""');
  });
});
