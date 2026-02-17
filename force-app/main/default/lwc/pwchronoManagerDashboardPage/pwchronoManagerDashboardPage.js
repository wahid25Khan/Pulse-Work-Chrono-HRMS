import { LightningElement } from "lwc";
import {
	initBootstrapCompat,
	teardownBootstrapCompat
} from "c/pwchronoBootstrapCompat";

export default class PwchronoManagerDashboardPage extends LightningElement {
	renderedCallback() {
		initBootstrapCompat(this);
	}

	disconnectedCallback() {
		teardownBootstrapCompat(this);
	}
}