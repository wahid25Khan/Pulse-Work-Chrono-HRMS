import smarthrAssets from "@salesforce/resourceUrl/smarthr_assets";
import { logError } from "c/pwchronoErrorHandler";
import { loadStyle } from "lightning/platformResourceLoader";
import { LightningElement } from "lwc";

const GLOBAL_PROMISE_KEY = "__pwchronoUiAssetsPromise";
const GLOBAL_LOADED_KEY = "__pwchronoUiAssetsLoaded";

export default class PwchronoUiAssets extends LightningElement {
  static renderMode = "light";

  renderedCallback() {
    // If styles are already loaded, nothing to do.
    if (globalThis[GLOBAL_LOADED_KEY]) {
      return;
    }

    // If a load is already in progress (or has completed), do not restart.
    if (!globalThis[GLOBAL_PROMISE_KEY]) {
      const cssUrls = [
        `${smarthrAssets}/assets/plugins/fontawesome/css/all.min.css`,
        `${smarthrAssets}/assets/plugins/tabler-icons/tabler-icons.min.css`,
        `${smarthrAssets}/assets/plugins/icons/feather/feather.css`,
        `${smarthrAssets}/assets/css/bootstrap.min.css`,
        `${smarthrAssets}/assets/css/style.css`
      ];

      globalThis[GLOBAL_PROMISE_KEY] = cssUrls
        .reduce(
          (p, url) => p.then(() => loadStyle(this, url)),
          Promise.resolve()
        )
        .then(() => {
          globalThis[GLOBAL_LOADED_KEY] = true;
        })
        .catch((e) => {
          // Keep UI functional even if a stylesheet fails to load.
          // Mark as loaded to avoid retry loops on every render.
          globalThis[GLOBAL_LOADED_KEY] = true;
          logError("pwchronoUiAssets: Failed to load UI assets", e);
        });
    }
  }
}