import { LightningElement } from 'lwc';
import smarthr_assets from '@salesforce/resourceUrl/smarthr_assets';

export default class PwchronoSidebar extends LightningElement {
    static renderMode = 'light';

    _layoutApplied = false;
    assetsBase = `${smarthr_assets}/assets`;

    get logoUrl() {
        return `${this.assetsBase}/img/logo.svg`;
    }

    get logoSmallUrl() {
        return `${this.assetsBase}/img/logo-small.svg`;
    }

    get logoWhiteUrl() {
        return `${this.assetsBase}/img/logo-white.svg`;
    }

    get profileAvatarUrl() {
        return `${this.assetsBase}/img/profiles/avatar-02.jpg`;
    }

    renderedCallback() {
        if (this._layoutApplied) return;
        this._layoutApplied = true;

        globalThis.document?.documentElement?.setAttribute('data-layout', 'modern');
        globalThis.document?.documentElement?.setAttribute('data-size', 'default');
    }
}
