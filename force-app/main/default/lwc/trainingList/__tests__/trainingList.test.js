import { createElement } from "lwc";
import TrainingList from "c/trainingList";

const flushPromises = () => Promise.resolve();

describe("c-training-list", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.restoreAllMocks();
  });

  function createComponent() {
    const element = createElement("c-training-list", {
      is: TrainingList
    });
    document.body.appendChild(element);
    return element;
  }

  it("adds and deletes a training record", async () => {
    jest.spyOn(Date, "now").mockReturnValue(2);
    const element = createComponent();
    await flushPromises();

    expect(element.shadowRoot.querySelectorAll("tbody tr")).toHaveLength(1);

    element.shadowRoot.querySelector('[data-action="openAdd"]').click();
    await flushPromises();

    const typeInput = element.shadowRoot.querySelector('input[name="type"]');
    typeInput.value = "Security Training";
    typeInput.dispatchEvent(new CustomEvent("change"));

    element.shadowRoot.querySelector('[data-action="save"]').click();
    await flushPromises();

    const rows = element.shadowRoot.querySelectorAll("tbody tr");
    expect(rows).toHaveLength(2);
    expect(rows[1].textContent).toContain("Security Training");

    rows[1].querySelector('[data-action="delete"]').click();
    await flushPromises();

    expect(element.shadowRoot.querySelectorAll("tbody tr")).toHaveLength(1);
  });

  it("edits an existing training record", async () => {
    const element = createComponent();
    await flushPromises();

    element.shadowRoot.querySelector('[data-action="edit"]').click();
    await flushPromises();

    const trainerInput = element.shadowRoot.querySelector(
      'input[name="trainerName"]'
    );
    trainerInput.value = "Updated Trainer";
    trainerInput.dispatchEvent(new CustomEvent("change"));

    element.shadowRoot.querySelector('[data-action="save"]').click();
    await flushPromises();

    const row = element.shadowRoot.querySelector("tbody tr");
    expect(row.textContent).toContain("Updated Trainer");
    expect(element.shadowRoot.querySelector(".modal")).toBeNull();
  });
});
