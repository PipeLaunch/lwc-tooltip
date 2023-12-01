//@ts-check

/**
 * @description computes the classes for the tooltip text
 * @param {"top-right"|"top-left"} align
 * @returns {string}
 */
export function tooltipTextClasses(align = "top-right") {
  const BASE_CLASSES = ["tooltip", "slds-popover", "slds-popover_tooltip"];

  switch (align) {
    case "top-right":
      BASE_CLASSES.push("slds-nubbin_bottom-right");
      BASE_CLASSES.push("tooltip-align-right");
      break;
    case "top-left":
      BASE_CLASSES.push("slds-nubbin_bottom-left");
      BASE_CLASSES.push("tooltip-align-left");
      break;
    default:
      break;
  }

  return BASE_CLASSES.join(" ");
}

/**
 * @description computes the styles for the tooltip text
 * @param {string} content
 * @returns {string}
 */
export function tooltipTextStyles(content) {
  if (typeof content === "string" && content?.length < 60) {
    return `min-width: ${content.length + 1}ch`;
  }

  return `width: 60ch`;
}
