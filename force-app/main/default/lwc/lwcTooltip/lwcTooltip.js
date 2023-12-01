/**
 * @description       : Shows a helpext in a tooltip tooltip
 * https://www.lightningdesignsystem.com/components/tooltips/
 *
 * @author            : samuel@pipelaunch.com
 * @group             : Generic Components
 * @last modified on  : 2023-12-01
 * @last modified by  : samuel@pipelaunch.com
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   2023-12-01   samuel@pipelaunch.com   Initial Version
 **/
import { LightningElement, api } from "lwc";

import { tooltipTextClasses, tooltipTextStyles } from "./computeStyles";

export default class LwcTooltip extends LightningElement {
  /**
   * @property {string} - Text to display
   */
  @api content = "";

  /**
   * @property {string} - Tooltip alignment
   * @values top-right, top-left
   */
  @api align = "top-right";

  /**
   * @type {string} - Returns the classes for the tooltip text
   */
  get computeTooltipTextClasses() {
    return tooltipTextClasses(this.align);
  }

  /**
   * @type {string} - Returns the styles for the tooltip text
   */
  get computeTooltipTextStyles() {
    return tooltipTextStyles(this.content);
  }
}
