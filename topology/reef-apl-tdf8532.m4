#
# Topology for generic Apollolake board with TDF8532
#

# Include topology builder
include(`utils.m4')
include(`dai.m4')
include(`pipeline.m4')

# Include TLV library
include(`common/tlv.m4')

# Include Token library
include(`sof/tokens.m4')

# Include Apollolake DSP configuration
include(`dsps/bxt.m4')

#
# Define the pipelines
#
# PCM0 ----> volume -----> SSP4
# PCM1 ----> volume -----> SSP2
# PCM2 <---- Volume <----- SSP2
#

# Low Latency playback pipeline 1 on PCM 0 using max 4 channels of s32le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
# Use DMAC 0 channel 1 for PCM audio playback data
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-playback.m4,
	1, 0, 4, s32le,
	48, 1000, 0, 0, 0, 1, SSP, 4, s32le, 2)

# Low Latency playback pipeline 3 on PCM 1 using max 4 channels of s32le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
# Use DMAC 0 channel 1 for PCM audio playback data
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-playback.m4,
	2, 1, 2, s16le,
	48, 1000, 0, 0, 0, 1, SSP, 2, s16le, 2)

# Low Latency playback pipeline 1 on PCM 0 using max 4 channels of s32le.
# Schedule 48 frames per 1000us deadline on core 0 with priority 0
# Use DMAC 0 channel 1 for PCM audio playback data
PIPELINE_PCM_DAI_ADD(sof/pipe-volume-capture.m4,
	3, 1, 2, s16le,
	48, 1000, 0, 0, 0, 1, SSP, 2, s16le, 2)
#
# DAI configuration
#

# playback DAI is SSP4 using 2 periods
# Buffers use s32le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	1, SSP, 4, SSP4-Codec,
	PIPELINE_SOURCE_1, 2, s32le,
	48, 1000, 0, 0)

# playback DAI is SSP2 using 2 periods
# Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	2, SSP, 2, SSP2-Codec,
	PIPELINE_SOURCE_2, 2, s16le,
	48, 1000, 0, 0)

# capture DAI is SSP2 using 2 periods
# Buffers use s16le format, with 48 frame per 1000us on core 0 with priority 0
DAI_ADD(sof/pipe-dai-capture.m4,
	3, SSP, 2, SSP2-Codec,
	PIPELINE_SINK_3, 2, s16le,
	48, 1000, 0, 0)

# PCM Low Latency, id 0
PCM_PLAYBACK_ADD(Port4, 1, 0, 0, PIPELINE_PCM_1)
PCM_DUPLEX_ADD(Port2, 4, 1, 1, PIPELINE_PCM_2, PIPELINE_PCM_3)

#
# BE configurations - overrides config in ACPI if present
#
DAI_CONFIG(SSP, 4, SSP4-Codec, DSP_B, 32,
	DAI_CLOCK(mclk, 24576000, slave),
	DAI_CLOCK(bclk, 12288000, slave),
	DAI_CLOCK(fsync, 48000, slave),
	DAI_TDM(8, 32, 15, 15))

DAI_CONFIG(SSP, 2, SSP2-Codec, I2S, 16,
	DAI_CLOCK(mclk, 24576000, slave),
	DAI_CLOCK(bclk, 1536000, slave),
	DAI_CLOCK(fsync, 48000, slave),
	DAI_TDM(2, 16, 3, 3))
