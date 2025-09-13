import React from "react"
import Svg, { SvgProps, Path, Circle, Line, Polyline, Polygon, Rect } from "react-native-svg"

const defaultProps = {
  width: 24,
  height: 24,
  viewBox: "0 0 24 24",
  fill: "none",
  stroke: "currentColor",
  strokeWidth: 2,
  strokeLinecap: "round",
  strokeLinejoin: "round",
}

export const SearchIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Circle cx="11" cy="11" r="8" />
    <Line x1="21" y1="21" x2="16.65" y2="16.65" />
  </Svg>
)

export const ChatIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
  </Svg>
)

export const SpeakerIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5" />
    <Path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07" />
  </Svg>
)

export const DepositIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z" />
    <Polyline points="17 21 17 13 7 13 7 21" />
    <Polyline points="7 3 7 8 15 8" />
  </Svg>
)

export const TransferIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Polyline points="17 1 21 5 17 9" />
    <Path d="M3 11V9a4 4 0 0 1 4-4h14" />
    <Polyline points="7 23 3 19 7 15" />
    <Path d="M21 13v2a4 4 0 0 1-4 4H3" />
  </Svg>
)

export const WithdrawIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Path d="M21 12V7H3v5" />
    <Path d="M12 12v6" />
    <Path d="M15 15l-3 3-3-3" />
    <Path d="M3 7V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v2" />
  </Svg>
)

export const VipIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
  </Svg>
)

export const PromoteIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
    <Circle cx="9" cy="7" r="4" />
    <Path d="M23 21v-2a4 4 0 0 0-3-3.87" />
    <Path d="M16 3.13a4 4 0 0 1 0 7.75" />
  </Svg>
)

export const SportsIcon = (props: SvgProps) => (
    <Svg {...defaultProps} {...props} fill="none" stroke="currentColor">
        <Path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-1-12h2v4h-2zm0 6h2v2h-2z" />
    </Svg>
)

export const LiveIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Rect x="3" y="3" width="7" height="7" />
    <Rect x="14" y="3" width="7" height="7" />
    <Rect x="14" y="14" width="7" height="7" />
    <Rect x="3" y="14" width="7" height="7" />
  </Svg>
)

export const ChessIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9" />
    <Path d="M13.73 21a2 2 0 0 1-3.46 0" />
  </Svg>
)

export const EsportsIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48" />
  </Svg>
)

export const LotteryIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Circle cx="12" cy="12" r="10" />
    <Path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" />
    <Line x1="12" y1="17" x2="12.01" y2="17" />
  </Svg>
)

export const SlotsIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z" />
    <Line x1="7" y1="7" x2="7.01" y2="7" />
  </Svg>
)

export const EntertainmentIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
  </Svg>
)

export const HomeIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
    <Polyline points="9 22 9 12 15 12 15 22" />
  </Svg>
)

export const GiftIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Polyline points="20 12 20 22 4 22 4 12" />
    <Rect x="2" y="7" width="20" height="5" />
    <Line x1="12" y1="22" x2="12" y2="7" />
    <Path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z" />
    <Path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z" />
  </Svg>
)

export const HeadphonesIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Path d="M21 12v3a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-3" />
    <Path d="M3 12A9 9 0 0 1 12 3v0a9 9 0 0 1 9 9" />
  </Svg>
)

export const SponsorIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" />
  </Svg>
)

export const UserIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
    <Circle cx="12" cy="7" r="4" />
  </Svg>
)

export const XIcon = (props: SvgProps) => (
  <Svg {...defaultProps} {...props}>
    <Line x1="18" y1="6" x2="6" y2="18" />
    <Line x1="6" y1="6" x2="18" y2="18" />
  </Svg>
)
