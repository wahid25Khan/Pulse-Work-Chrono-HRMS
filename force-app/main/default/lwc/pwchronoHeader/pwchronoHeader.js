import { LightningElement } from 'lwc';
import smarthr_assets from '@salesforce/resourceUrl/smarthr_assets';

export default class PwchronoHeader extends LightningElement {
    assetsBase = `${smarthr_assets}/assets`;

    get logoUrl() {
        return `${this.assetsBase}/img/logo.svg`;
    }

    get logoWhiteUrl() {
        return `${this.assetsBase}/img/logo-white.svg`;
    }

    get avatar27Url() {
        return `${this.assetsBase}/img/profiles/avatar-27.jpg`;
    }

    get avatar23Url() {
        return `${this.assetsBase}/img/profiles/avatar-23.jpg`;
    }

    get avatar25Url() {
        return `${this.assetsBase}/img/profiles/avatar-25.jpg`;
    }

    get avatar01Url() {
        return `${this.assetsBase}/img/profiles/avatar-01.jpg`;
    }

    get avatar12Url() {
        return `${this.assetsBase}/img/profiles/avatar-12.jpg`;
    }
}