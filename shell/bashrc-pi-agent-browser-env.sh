# agent_browser: cap inline screenshot attachments.
#
# Screenshots are by far the most expensive thing an agent can put into its own
# context. Measured in a real session: ONE inline base64 screenshot was 99 KB =
# 29% of all tool output, while a full `snapshot -i` accessibility dump averages
# ~2.5 KB. Two screenshots cost more than the other 64 browser calls combined.
#
# Above this bound the image is STILL captured, STILL written to its path, and
# STILL reports path / mime type / pixel dimensions / artifact verification.
# Only the base64 attachment is skipped, with an explicit notice:
#
#   Image attachment skipped: 74.2 KiB exceeds the inline limit of 20 KiB.
#
# Nothing is lost: when an image genuinely needs looking at, read the saved
# path and it attaches deliberately. Small deliberate images (crops, icons,
# agent_browser_code emitImage) stay under the bound and still inline.
#
# Verified end-to-end with the bound forced to 1 B: the PNG saved fine (16,562
# bytes, valid 1280x633) and only the attachment was dropped; at 20480 a 16 KiB
# image still inlined -- so the threshold discriminates in both directions.
#
# This is the only PI_AGENT_BROWSER_* variable that affects model context; the
# others are timeouts, socket dirs and disk budgets.
export PI_AGENT_BROWSER_INLINE_IMAGE_MAX_BYTES=20480
