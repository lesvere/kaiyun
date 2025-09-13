const palette = {
  neutral100: "#FFFFFF",
  neutral200: "#F4F2F1",
  neutral300: "#D7CEC9",
  neutral400: "#B6ACA6",
  neutral500: "#978F8A",
  neutral600: "#564E4A",
  neutral700: "#3C3836",
  neutral800: "#191015",
  neutral900: "#000000",

  primary100: "#F4E0D9",
  primary200: "#E8C1B4",
  primary300: "#DDA28E",
  primary400: "#D28468",
  primary500: "#C76542",
  primary600: "#A54F31",

  secondary100: "#DCDDE9",
  secondary200: "#BCC0D6",
  secondary300: "#9196B9",
  secondary400: "#626894",
  secondary500: "#41476E",

  accent100: "#FFEED4",
  accent200: "#FFE1B2",
  accent300: "#FDD495",
  accent400: "#FBC878",
  accent500: "#FFBB50",

  angry100: "#F2D6CD",
  angry500: "#C03403",

  overlay20: "rgba(25, 16, 21, 0.2)",
  overlay50: "rgba(25, 16, 21, 0.5)",

  // New colors from the Kaiyun project
  kaiyun_background: "#f0f2f5",
  kaiyun_white: "#ffffff",
  kaiyun_primaryBlue: "#3a7fff",
  kaiyun_textPrimary: "#333333",
  kaiyun_textSecondary: "#888888",
  kaiyun_textLight: "#5e6a7d",
  kaiyun_border: "#eeeeee",
  kaiyun_cardBg: "#ffffff", // from linear-gradient
  kaiyun_buttonGradient: "#3a7fff", // from linear-gradient
  kaiyun_iconBg: "#3876fe", // from linear-gradient
  kaiyun_activeIconBg: "#2968ec", // from linear-gradient
} as const

export const colors = {
  /**
   * The palette is available to use, but prefer using the name.
   * This is only included for rare, one-off cases. Try to use
   * semantic names as much as possible.
   */
  palette,
  /**
   * A helper for making something see-thru.
   */
  transparent: "rgba(0, 0, 0, 0)",
  /**
   * The default text color in many components.
   */
  text: palette.kaiyun_textPrimary,
  /**
   * Secondary text information.
   */
  textDim: palette.kaiyun_textSecondary,
  /**
   * The default color of the screen background.
   */
  background: palette.kaiyun_background,
  /**
   * The default border color.
   */
  border: palette.kaiyun_border,
  /**
   * The main tinting color.
   */
  tint: palette.kaiyun_primaryBlue,
  /**
   * The inactive tinting color.
   */
  tintInactive: palette.neutral300,
  /**
   * A subtle color used for lines.
   */
  separator: palette.kaiyun_border,
  /**
   * Error messages.
   */
  error: palette.angry500,
  /**
   * Error Background.
   */
  errorBackground: palette.angry100,
} as const
