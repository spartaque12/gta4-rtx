//! remixfx effect.id      = lens_drops
//! remixfx effect.name    = Lens Drops
//! remixfx effect.domain  = display
//! remixfx effect.enabled = true

// Fusion Rain Droplets (ThirteenAG/FusionRainDroplets, source/xrd) as a RemixFX
// effect: the same drops, the same way. The simulation is xrd.h's WaterDrops
// (SpawnDrops, the air over the lens of CalculateMovement, MoveDrop, NewTrace,
// Fade) run on the GPU over a pool of drops kept in a persistent texture, the
// quads are the ones AddToRenderList builds, and they are drawn with the pixel
// shader of Direct3D 9 (source/shaders/d3d9/drops.hlsl), its light field
// (light.hlsl) and the mip chain of the copy of the frame, over the atlas of
// the drop shapes (source/resources/lensdrops.png). Snow is not ported.
//
// What the game hands the effect comes in through parameters bound to game
// values (param.<id>.gamevalue, written with SetGameValue). GTA IV: the RTX
// compatibility mod writes them, see lens_fx in timecycle.cpp:
//
//   gameRain      gta4.lens.rain      ms_rainIntensity of the frame
//   gameBlood     gta4.lens.blood     blood on the camera, event counter (FillScreenMoving(50, true))
//   gameSplash    gta4.lens.splash    water on the camera, a running count of drops (FillScreenMoving)
//   gameSpray     gta4.lens.spray     a spray the camera stands in, FillScreenMovingRate of the frame
//   gameTimestep  gta4.lens.timestep  the frame time of the game in seconds; below 0 the runtime's is used

//! remixfx param.category        = Drops
//! remixfx param.minSize         = float 4 [1..100] step 1
//! remixfx param.minSize.label   = Minimum Drop Size
//! remixfx param.minSize.tooltip = Size of the smallest drops, in pixels at a screen height of 480; scaled to the resolution.
//! remixfx param.maxSize         = float 19 [1..100] step 1
//! remixfx param.maxSize.label   = Maximum Drop Size
//! remixfx param.maxSize.tooltip = Size of the largest drops, in pixels at a screen height of 480; scaled to the resolution.
//! remixfx param.maxDrops        = float 3000 [100..4096] step 1
//! remixfx param.maxDrops.label  = Maximum Drops
//! remixfx param.maxDrops.tooltip = The most drops on the screen at once, including the water trails they leave.
//! remixfx param.gravity         = bool true
//! remixfx param.gravity.label   = Gravity
//! remixfx param.gravity.tooltip = Some of the drops slowly run down the screen.
//! remixfx param.refractions     = bool true
//! remixfx param.refractions.label = Refractions
//! remixfx param.refractions.tooltip = Drops gather the light around them and leave bands of water; off, they leave small drops.
//! remixfx param.speedAdjuster   = float 1 [0..5] step 0.05
//! remixfx param.speedAdjuster.label = Speed Multiplier
//! remixfx param.speedAdjuster.tooltip = How strongly camera movement moves the drops.
//! remixfx param.moveStep        = float 0.1 [0..5] step 0.05
//! remixfx param.moveStep.label  = Movement Step
//! remixfx param.moveStep.tooltip = Spacing of the trail a running drop leaves, in pixels.
//! remixfx param.dropBlur        = float 1 [0..1] step 0.01
//! remixfx param.dropBlur.label  = Drop Blur
//! remixfx param.dropBlur.tooltip = 0: clear drops that show the picture sharply. 1: soft, blurred drops.
//! remixfx param.fixedPlacement  = bool true
//! remixfx param.fixedPlacement.label = Fixed Placement
//! remixfx param.fixedPlacement.tooltip = Drops land evenly spread and away from the middle of the screen. Off: drops land at random.
//! remixfx param.lightSteadiness = float 0.75 [0..0.95] step 0.05
//! remixfx param.lightSteadiness.label = Light Steadiness
//! remixfx param.lightSteadiness.tooltip = How much of the light a drop gathers is carried over from the frames before. A small light (a tail light) falls between the points the light is gathered at on some frames and not on others, which makes the glow of the drops flicker. 0: as Fusion Rain Droplets, every frame on its own.

//! remixfx param.category        = Blood
//! remixfx param.bloodDrops      = bool true
//! remixfx param.bloodDrops.label = Blood Droplets
//! remixfx param.bloodAmount     = float 1 [0..3] step 0.05
//! remixfx param.bloodAmount.label = Blood Amount
//! remixfx param.bloodAmount.tooltip = Blood drops per splatter, 1.0 = as the game asks.
//! remixfx param.bloodOpacity    = float 1 [0..1] step 0.01
//! remixfx param.bloodOpacity.label = Blood Opacity

//! remixfx param.category        = Game
//! remixfx param.forceRain       = bool false
//! remixfx param.forceRain.label = Force Rain
//! remixfx param.forceRain.tooltip = Shows drops in any weather, for trying out the settings.
//! remixfx param.gameRain        = float 0 [0..1] step 0.01
//! remixfx param.gameRain.label  = Game Rain
//! remixfx param.gameRain.gamevalue = gta4.lens.rain
//! remixfx param.gameBlood       = float 0 [0..1000000] step 1
//! remixfx param.gameBlood.label = Game Blood Hits
//! remixfx param.gameBlood.gamevalue = gta4.lens.blood
//! remixfx param.gameSplash      = float 0 [0..100000000] step 1
//! remixfx param.gameSplash.label = Game Splash Drops
//! remixfx param.gameSplash.gamevalue = gta4.lens.splash
//! remixfx param.gameSpray       = float 0 [0..50] step 0.1
//! remixfx param.gameSpray.label = Game Spray
//! remixfx param.gameSpray.gamevalue = gta4.lens.spray
//! remixfx param.gameTimestep    = float -1 [-1..1] step 0.001
//! remixfx param.gameTimestep.label = Game Timestep
//! remixfx param.gameTimestep.gamevalue = gta4.lens.timestep

//! remixfx texture.mask.file = lensdrops.png
//! remixfx texture.drops   = rgba32f size 4096 9 persist
//! remixfx texture.quads   = rgba32f size 4096 18
//! remixfx texture.state   = rgba32f size 8 1 persist
//! remixfx texture.landing = rg32f size 834 1 persist
//! remixfx texture.light   = rgba16f div 8 persist
//! remixfx texture.bins    = r32u div 4
//! remixfx texture.mip1    = rgba16f div 2
//! remixfx texture.mip2    = rgba16f div 4
//! remixfx texture.mip3    = rgba16f div 8
//! remixfx texture.mip4    = rgba16f div 16
//! remixfx texture.mip5    = rgba16f div 32
//! remixfx texture.mip6    = rgba16f div 64
//! remixfx texture.mip7    = rgba16f div 128
//! remixfx texture.mip8    = rgba16f div 256

//! remixfx pass.simulate  = entry simulateMain once write drops write quads write state write landing
//! remixfx pass.mip1      = entry mip1Main over mip1 write mip1
//! remixfx pass.mip2      = entry mip2Main over mip2 read mip1 write mip2
//! remixfx pass.mip3      = entry mip3Main over mip3 read mip2 write mip3
//! remixfx pass.mip4      = entry mip4Main over mip4 read mip3 write mip4
//! remixfx pass.mip5      = entry mip5Main over mip5 read mip4 write mip5
//! remixfx pass.mip6      = entry mip6Main over mip6 read mip5 write mip6
//! remixfx pass.mip7      = entry mip7Main over mip7 read mip6 write mip7
//! remixfx pass.mip8      = entry mip8Main over mip8 read mip7 write mip8
//! remixfx pass.light     = entry lightMain over light write light
//! remixfx pass.bin       = entry binMain over bins read quads write bins
//! remixfx pass.composite = entry compositeMain over output read mask read quads read light read bins read mip1 read mip2 read mip3 read mip4 read mip5 read mip6 read mip7 read mip8 write output

#include "remixfx_bindings.slangh"
#include "lens_landing.slangh"

REMIXFX_READ(REMIXFX_TEX_mask)     Sampler2D<float4>   Mask;
REMIXFX_WRITE(REMIXFX_TEX_drops)   RWTexture2D<float4> DropsRW;
REMIXFX_READ(REMIXFX_TEX_quads)    Texture2D<float4>   Quads;
REMIXFX_WRITE(REMIXFX_TEX_quads)   RWTexture2D<float4> QuadsRW;
REMIXFX_WRITE(REMIXFX_TEX_state)   RWTexture2D<float4> StateRW;
REMIXFX_WRITE(REMIXFX_TEX_landing) RWTexture2D<float2> LandingRW;
REMIXFX_READ(REMIXFX_TEX_light)    Texture2D<float4>   LightField;
REMIXFX_WRITE(REMIXFX_TEX_light)   RWTexture2D<float4> LightFieldRW;
REMIXFX_READ(REMIXFX_TEX_bins)     Texture2D<uint>     Bins;
REMIXFX_WRITE(REMIXFX_TEX_bins)    RWTexture2D<uint>   BinsRW;
REMIXFX_READ(REMIXFX_TEX_mip1)     Texture2D<float4>   Mip1;
REMIXFX_WRITE(REMIXFX_TEX_mip1)    RWTexture2D<float4> Mip1RW;
REMIXFX_READ(REMIXFX_TEX_mip2)     Texture2D<float4>   Mip2;
REMIXFX_WRITE(REMIXFX_TEX_mip2)    RWTexture2D<float4> Mip2RW;
REMIXFX_READ(REMIXFX_TEX_mip3)     Texture2D<float4>   Mip3;
REMIXFX_WRITE(REMIXFX_TEX_mip3)    RWTexture2D<float4> Mip3RW;
REMIXFX_READ(REMIXFX_TEX_mip4)     Texture2D<float4>   Mip4;
REMIXFX_WRITE(REMIXFX_TEX_mip4)    RWTexture2D<float4> Mip4RW;
REMIXFX_READ(REMIXFX_TEX_mip5)     Texture2D<float4>   Mip5;
REMIXFX_WRITE(REMIXFX_TEX_mip5)    RWTexture2D<float4> Mip5RW;
REMIXFX_READ(REMIXFX_TEX_mip6)     Texture2D<float4>   Mip6;
REMIXFX_WRITE(REMIXFX_TEX_mip6)    RWTexture2D<float4> Mip6RW;
REMIXFX_READ(REMIXFX_TEX_mip7)     Texture2D<float4>   Mip7;
REMIXFX_WRITE(REMIXFX_TEX_mip7)    RWTexture2D<float4> Mip7RW;
REMIXFX_READ(REMIXFX_TEX_mip8)     Texture2D<float4>   Mip8;
REMIXFX_WRITE(REMIXFX_TEX_mip8)    RWTexture2D<float4> Mip8RW;

// ---------------------------------------------------------------------------
// parameters

static const uint kMinSize = 0u;
static const uint kMaxSize = 1u;
static const uint kMaxDrops = 2u;
static const uint kGravity = 3u;
static const uint kRefractions = 4u;
static const uint kSpeedAdjuster = 5u;
static const uint kMoveStep = 6u;
static const uint kDropBlur = 7u;
static const uint kFixedPlacement = 8u;
static const uint kLightSteadiness = 9u;
static const uint kBloodDrops = 10u;
static const uint kBloodAmount = 11u;
static const uint kBloodOpacity = 12u;
static const uint kForceRain = 13u;
static const uint kGameRain = 14u;
static const uint kGameBlood = 15u;
static const uint kGameSplash = 16u;
static const uint kGameSpray = 17u;
static const uint kGameTimestep = 18u;

// ---------------------------------------------------------------------------
// xrd.h's constants, same names, same values (times in seconds: the effect's
// own unit is two thousand to the second)

static const uint  kPool = 4096u;
static const uint  kThreads = 1024u;
static const uint  kPerThread = 4u;
static const uint  kMaxSpawns = 512u;
static const uint  kTileSize = 64u;
static const uint  kTileEntries = 255u;

static const float SizeToMagnitude = 3.12f;
static const float LensRadialGain = 0.5f;
static const float LensLateralGain = 0.9f;
static const float LensTilt = 0.87f;
static const float MinAlignment = 0.55f;
static const float LifeMinSeconds = 3.0f;
static const float WeatherDropsPerSecond = 250.0f;
static const float LandingScale = 1.41421356f;
static const float CenterPush = 0.5f;
static const float CenterPushSkip = 0.001f;
static const float PushStartSpeed = 2.0f;
static const float PushFullSpeed = 25.0f;
static const float BloodHoldSeconds = 2.0f;
static const float BloodHoldSpread = 1.5f;
static const float BloodFadeSeconds = 1.5f;
static const float SplashScale = 1.4f;
static const float SplashSeconds = 0.0157f;
static const float BigDropShare = 0.13f;
static const float LookArm = 108.0f;
static const float LookAirMax = 120.0f;
static const float CutSpeed = 150.0f;
static const float CutTurn = 0.35f;
static const float LookFadeStart = 3.0f;
static const float LookFadeEnd = 10.0f;
static const float LookSettle = 0.12f;
static const float LookGrip = 10.0f;
static const float LookGripSpread = 0.4f;
static const float LookHeading = 0.25f;
static const float SlipStall = 0.8f;
static const float LookSag = 0.18f;
static const float GravityShare = 0.35f;
static const float GravitySlowest = 8.0f;
static const float GravityFastest = 22.0f;
static const float GravityRise = 0.4f;
static const float TraceLifeMin = 0.6f;
static const float TraceLifeMax = 1.8f;
static const float PoolReserveShare = 0.2f;
static const float TrailWidthShare = 0.5f;
static const float TrailWidest = 0.45f;
static const float TrailThin = 0.6f;
static const float TeardropHead = 0.7f;
static const float TeardropLength = 1.4f;
static const float TrailSharpTurn = 1.2f;
static const float TrailFadeIn = 1.0f;
static const float TrailDrain = 0.08f;
static const float TrailSmallest = 1.5f;
static const float TrailSpeed = 12.0f;
static const float ShovedTrailSpeed = 3.0f;
static const float SettleBelow = 2.0f;
static const float TraceShare = 0.55f;
static const float Refraction = 7.0f;
static const int   AtlasTiles = 4;
static const int   AtlasShapes = 14;
static const float ShapeShare = 0.6f;
static const float LensWindow = 0.4f;
static const float AtlasLightMarker = 2.0f;
static const float Pi = 3.14159265f;
static const float TwoPi = 6.2831853f;
static const float OneUnit = 0.0005f; // one of the effect's own units of time, in seconds

// light.hlsl / D3D9Light
static const int   LightCellCount = 6;
static const float LightRadius = 0.14f;

// drop flags
static const uint kActive = 1u;
static const uint kTrace = 2u;
static const uint kBlood = 4u;
static const uint kTrail = 8u;
static const uint kShoved = 16u;
static const uint kLinked = 32u;
static const uint kMoving = 64u;

// ---------------------------------------------------------------------------
// the drop, xrd.h's WaterDrop, in nine texels of the pool texture

struct Drop {
  float x, y, size, time;
  float ttl, alpha0, alpha;
  uint flags;
  int uvIndex;
  float3 vel;
  float rotation;
  float fall, fallTop, shapeX, shapeY;
  float meander, meanderSeed, headSize, grip;
  float slip, heading, run, linkRun;
  float linkX, linkY, linkAngle, linkAge;
  float linkSpeed, linkSize, linkHead, linkAlpha;
  float traceTtl, dist;

  bool has(uint f) { return (flags & f) != 0u; }
  [mutating] void set(uint f, bool on) { flags = on ? (flags | f) : (flags & ~f); }
};

Drop loadDrop(uint slot) {
  const float4 r0 = DropsRW[uint2(slot, 0u)];
  const float4 r1 = DropsRW[uint2(slot, 1u)];
  const float4 r2 = DropsRW[uint2(slot, 2u)];
  const float4 r3 = DropsRW[uint2(slot, 3u)];
  const float4 r4 = DropsRW[uint2(slot, 4u)];
  const float4 r5 = DropsRW[uint2(slot, 5u)];
  const float4 r6 = DropsRW[uint2(slot, 6u)];
  const float4 r7 = DropsRW[uint2(slot, 7u)];
  const float4 r8 = DropsRW[uint2(slot, 8u)];
  Drop d;
  d.x = r0.x; d.y = r0.y; d.size = r0.z; d.time = r0.w;
  d.ttl = r1.x; d.alpha0 = r1.y; d.flags = uint(r1.z + 0.5f); d.uvIndex = int(round(r1.w));
  d.vel = r2.xyz; d.rotation = r2.w;
  d.fall = r3.x; d.fallTop = r3.y; d.shapeX = r3.z; d.shapeY = r3.w;
  d.meander = r4.x; d.meanderSeed = r4.y; d.headSize = r4.z; d.grip = r4.w;
  d.slip = r5.x; d.heading = r5.y; d.run = r5.z; d.linkRun = r5.w;
  d.linkX = r6.x; d.linkY = r6.y; d.linkAngle = r6.z; d.linkAge = r6.w;
  d.linkSpeed = r7.x; d.linkSize = r7.y; d.linkHead = r7.z; d.linkAlpha = r7.w;
  d.traceTtl = r8.x; d.dist = r8.y; d.alpha = r8.z;
  return d;
}

void storeDrop(uint slot, Drop d) {
  DropsRW[uint2(slot, 0u)] = float4(d.x, d.y, d.size, d.time);
  DropsRW[uint2(slot, 1u)] = float4(d.ttl, d.alpha0, float(d.flags), float(d.uvIndex));
  DropsRW[uint2(slot, 2u)] = float4(d.vel, d.rotation);
  DropsRW[uint2(slot, 3u)] = float4(d.fall, d.fallTop, d.shapeX, d.shapeY);
  DropsRW[uint2(slot, 4u)] = float4(d.meander, d.meanderSeed, d.headSize, d.grip);
  DropsRW[uint2(slot, 5u)] = float4(d.slip, d.heading, d.run, d.linkRun);
  DropsRW[uint2(slot, 6u)] = float4(d.linkX, d.linkY, d.linkAngle, d.linkAge);
  DropsRW[uint2(slot, 7u)] = float4(d.linkSpeed, d.linkSize, d.linkHead, d.linkAlpha);
  DropsRW[uint2(slot, 8u)] = float4(d.traceTtl, d.dist, d.alpha, 0.0f);
}

// ---------------------------------------------------------------------------
// random numbers: GetRandomFloat(range) of a stream keyed by the frame and a key

uint hash(uint x) {
  x ^= x >> 16u; x *= 0x7feb352du;
  x ^= x >> 15u; x *= 0x846ca68bu;
  x ^= x >> 16u;
  return x;
}

struct Random {
  uint state;
  [mutating] float next(float range) {
    state = hash(state + 0x9E3779B9u);
    return float(state & 0x00FFFFFFu) / 16777216.0f * range;
  }
};

Random makeRandom(uint key) {
  Random r;
  r.state = hash(key ^ hash(cb.frameIndex * 0x85EBCA6Bu + 0x1234567u));
  return r;
}

// ---------------------------------------------------------------------------
// the frame, ms_fbWidth / ms_fbHeight / ms_scaling

float2 fbSize() { return float2(remixFxFrame.outputSize); }
float Scale() { return float(remixFxFrame.outputSize.y) / 480.0f; }
float SC(float v) { return float(int(v * Scale())); }

bool ribbons() { return remixFxParamBool(kRefractions); } // TrailRibbons: GatheredLight and the atlas

float smooth01(float t) { return t * t * (3.0f - 2.0f * t); }

float remainderTwoPi(float v) { return v - round(v / TwoPi) * TwoPi; }

float Meander(Drop d, float s) {
  const float seed = d.meanderSeed;
  const float size = max(d.size, 1.0f);
  const float longWave = size * (5.0f + 4.0f * seed);
  const float shortWave = size * (1.8f + 0.8f * frac(seed * 7.31f));
  const float longSway = size * (0.12f + 0.13f * frac(seed * 3.17f));
  const float shortSway = size * (0.03f + 0.03f * frac(seed * 5.53f));
  return longSway * sin(s / longWave * TwoPi + seed * 40.0f) + shortSway * sin(s / shortWave * TwoPi + seed * 90.0f);
}

float TrailSwell(Drop d, float s) {
  const float seed = d.meanderSeed;
  const float size = max(d.size, 1.0f);
  const float slow = sin(s / (size * (3.0f + 2.0f * frac(seed * 2.71f))) * TwoPi + seed * 17.0f);
  const float quick = sin(s / (size * (1.1f + 0.6f * frac(seed * 4.43f))) * TwoPi + seed * 29.0f);
  return clamp(1.0f + 0.12f * slow + 0.05f * quick, 0.8f, 1.2f);
}

float Slip(Drop d, float s) {
  const float seed = frac(d.meanderSeed * 8.91f);
  const float size = max(d.size, 1.0f);
  const float caught = pow(max(0.0f, sin(s / (size * (1.5f + 1.5f * seed)) * TwoPi + seed * 23.0f)), 6.0f);
  return 1.0f - SlipStall * caught;
}

float RibbonSize(Drop d) {
  return max(2.0f * Scale(), min(d.size * TrailWidthShare, TrailWidest * SC(remixFxParam(kMaxSize))) * TrailSwell(d, d.meander));
}

float LensAlignment(float px, float py, float3 air) {
  const float length3 = length(air);
  if (length3 <= 0.0f) {
    return MinAlignment;
  }
  const float nx = LensTilt * clamp(px, -1.0f, 1.0f);
  const float ny = LensTilt * clamp(py, -1.0f, 1.0f);
  const float nz = sqrt(max(0.0f, 1.0f - nx * nx - ny * ny));
  return max(abs(nx * air.x + ny * air.y + nz * air.z) / length3, MinAlignment);
}

float LandingShareOf(float push) {
  const float share[8] = { 1.0f, 0.836f, 0.684f, 0.546f, 0.424f, 0.319f, 0.227f, 0.153f };
  const float at = clamp(push * 10.0f, 0.0f, 7.0f);
  const int i = min(int(at), 6);
  return share[i] + (share[i + 1] - share[i]) * (at - float(i));
}

float RainCurve(float rain) {
  if (!(rain >= 0.04f)) {
    return 0.0f;
  }
  if (rain < 0.5f) {
    return (rain - 0.04f) * 1.0869565f;
  }
  return rain;
}

float DrawnStretch(float speed, float size) {
  return 1.0f + min(1.2f, speed / 60.0f * 0.9f / max(size, 1.0f));
}

float DrawnSize(Drop d) {
  if (d.has(kTrace)) {
    return d.size;
  }
  const float age = d.time;
  if (age >= SplashSeconds) {
    return d.size;
  }
  const float t = clamp(age / SplashSeconds, 0.0f, 1.0f);
  return d.size * (SplashScale + (1.0f - SplashScale) * smooth01(t));
}

float TrailWidthAt(float age, float speed, float size, float head) {
  head = max(head, size);
  const float line = max(1.2f * Scale(), size * TrailThin);
  const float widest = head * TeardropHead / sqrt(DrawnStretch(speed, head));
  const float t = clamp(age * speed / (TeardropLength * head), 0.0f, 1.0f);
  return line + max(widest - line, 0.0f) * (1.0f - smooth01(t));
}

// IsLens: clear water (not blood) that gathers the light, and the band of water a drop leaves
bool isLens(Drop d) {
  const bool water = !d.has(kTrace) || (d.uvIndex == AtlasShapes && ribbons());
  return water && !d.has(kBlood) && remixFxParamBool(kRefractions);
}

// ---------------------------------------------------------------------------
// the simulation: WaterDrops::Process of one frame, one workgroup over the pool

groupshared uint gsFree[kPool / 2u];
groupshared uint gsTraces[kPool / 2u];
groupshared float4 gsSpawn[kMaxSpawns];
groupshared uint gsFreeCount;
groupshared uint gsTraceCount;
groupshared uint gsHeads;
groupshared uint gsSpawnCount;
groupshared uint gsUsedFree;
groupshared uint gsEvicted;
groupshared uint gsDeposits;
groupshared uint gsNumDrops;
groupshared uint gsReset;

uint readList16(uint word, uint index) {
  return (word >> ((index & 1u) * 16u)) & 0xFFFFu;
}

// the slot a new drop takes: a free one, or the water of a trail
uint spawnSlot(uint k) {
  if (k < gsFreeCount) {
    return readList16(gsFree[k >> 1u], k);
  }
  const uint t = k - gsFreeCount;
  return readList16(gsTraces[t >> 1u], t);
}

// PlaceNew: the drop as it lands
Drop placeNew(float x, float y, float size, float ttl, bool isTrace, bool blood, inout Random rnd) {
  Drop d = (Drop)0;
  d.x = x;
  d.y = y;
  d.size = size;
  d.uvIndex = int(min(rnd.next(float(AtlasShapes)), float(AtlasShapes - 1)));
  d.flags = kActive | (isTrace ? kTrace : 0u);
  d.alpha = 255.0f;
  d.alpha0 = 255.0f;
  d.time = 0.0f;
  d.ttl = ttl;
  d.vel = 0.0f;
  d.fall = 0.0f;
  d.fallTop = 0.0f;
  if (!isTrace && rnd.next(1.0f) < GravityShare) {
    d.fallTop = (GravitySlowest + rnd.next(GravityFastest - GravitySlowest)) * Scale();
  }
  d.rotation = rnd.next(TwoPi) - Pi;
  const float wet = (d.size - SC(remixFxParam(kMinSize))) / max(1.0f, SC(remixFxParam(kMaxSize)) - SC(remixFxParam(kMinSize)));
  const bool trail = !isTrace && rnd.next(1.0f) < 0.35f + 0.45f * saturate(wet);
  d.set(kTrail, trail);
  d.traceTtl = (TraceLifeMin + rnd.next(TraceLifeMax - TraceLifeMin)) * 2000.0f * OneUnit;
  d.shapeX = 0.0f;
  d.shapeY = 0.0f;
  d.meander = 0.0f;
  d.meanderSeed = rnd.next(1.0f);
  d.headSize = 0.0f;
  d.grip = 1.0f + LookGripSpread * (rnd.next(2.0f) - 1.0f);
  d.slip = 0.0f;
  d.heading = LookHeading * (rnd.next(2.0f) - 1.0f);
  d.dist = 0.0f;

  if (blood) {
    // see SpawnDrops: blood sticks, leaves nothing, and is only as opaque as BloodOpacity says
    d.alpha0 = float(uint(d.alpha0 * remixFxParam(kBloodOpacity)));
    d.alpha = float(uint(d.alpha * remixFxParam(kBloodOpacity)));
    d.set(kBlood, true);
    d.set(kTrail, false);
    d.fallTop = 0.0f;
  } else if (!isTrace) {
    d.set(kMoving, true); // NewDropMoving
  }
  return d;
}

// The camera, the way the adapter of GTA IV hands it over: right of the screen,
// up and forward, and where it is, in units of the game.
struct Camera {
  float3 screenRight;
  float3 up;
  float3 fwd;
  float3 pos;
};

Camera currentCamera() {
  const float3 f = remixFxViewDirection(float2(0.5f, 0.5f), false);
  const float3 r = remixFxViewDirection(float2(1.0f, 0.5f), false);
  const float3 u = remixFxViewDirection(float2(0.5f, 0.0f), false);
  Camera c;
  c.fwd = normalize(mul(remixFxFrame.viewToWorld, float4(f, 0.0f)).xyz);
  c.screenRight = normalize(mul(remixFxFrame.viewToWorld, float4(normalize(r - f * dot(r, f)), 0.0f)).xyz);
  c.up = normalize(mul(remixFxFrame.viewToWorld, float4(normalize(u - f * dot(u, f)), 0.0f)).xyz);
  c.pos = mul(remixFxFrame.viewToWorld, float4(0.0f, 0.0f, 0.0f, 1.0f)).xyz / max(remixFxFrame.meterToWorldScale, 1e-6f);
  return c;
}

// one quad of the effect: four screen vertices, xrd's Vertex
struct QuadVertex {
  float2 pos;
  float2 atlas;
  float2 scene;
  float alpha;   // 0..255
  float redOnly; // the colour of blood, 0xFF0000
};

void writeVertex(uint slot, uint quad, uint v, QuadVertex q) {
  const uint row = 2u + quad * 8u + v * 2u;
  QuadsRW[uint2(slot, row)] = float4(q.pos, q.atlas);
  QuadsRW[uint2(slot, row + 1u)] = float4(q.scene, q.alpha, q.redOnly);
}

QuadVertex readVertex(uint slot, uint quad, uint v) {
  const uint row = 2u + quad * 8u + v * 2u;
  const float4 a = Quads.Load(int3(int(slot), int(row), 0));
  const float4 b = Quads.Load(int3(int(slot), int(row + 1u), 0));
  QuadVertex q;
  q.pos = a.xy;
  q.atlas = a.zw;
  q.scene = b.xy;
  q.alpha = b.z;
  q.redOnly = b.w;
  return q;
}

// AddDropQuad
void addDropQuad(uint slot, uint quad, float x, float y, float size, float alpha, bool red, int uvIndex, bool lens,
                 float rotation, float velocityX, float velocityY, inout float4 box) {
  const float tileSize = 1.0f / float(AtlasTiles);
  const float u0 = float(uvIndex % AtlasTiles) * tileSize;
  const float v0 = float(uvIndex / AtlasTiles) * tileSize;
  const float uv[8] = { u0, v0, u0, v0 + tileSize, u0 + tileSize, v0 + tileSize, u0 + tileSize, v0 };
  const float xy[8] = { -1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f, 1.0f, -1.0f };
  const float2 fb = fbSize();
  const float cu = x / fb.x;
  const float cv = y / fb.y;
  const float scale = size * 0.5f / ShapeShare;
  const float c = cos(rotation);
  const float sn = sin(rotation);
  const float speed = sqrt(velocityX * velocityX + velocityY * velocityY);
  const float stretch = DrawnStretch(speed, size);
  const float ax = speed > 0.001f ? velocityX / speed : 1.0f;
  const float ay = speed > 0.001f ? velocityY / speed : 0.0f;

  for (uint i = 0u; i < 4u; i++) {
    const float rx = xy[i * 2u] * c - xy[i * 2u + 1u] * sn;
    const float ry = xy[i * 2u] * sn + xy[i * 2u + 1u] * c;
    const float along = (rx * ax + ry * ay) * stretch;
    const float across = (-rx * ay + ry * ax) / sqrt(stretch);
    const float ox = along * ax - across * ay;
    const float oy = along * ay + across * ax;
    QuadVertex q;
    q.pos = float2(x + ox * scale, y + oy * scale);
    q.atlas = float2(uv[i * 2u] - (lens ? AtlasLightMarker : 0.0f), uv[i * 2u + 1u]);
    q.scene = float2(cu - ox * LensWindow, cv - oy * LensWindow);
    q.alpha = alpha;
    q.redOnly = red ? 1.0f : 0.0f;
    writeVertex(slot, quad, i, q);
    box = float4(min(box.xy, q.pos), max(box.zw, q.pos));
  }
}

// AddRibbonQuad
void addRibbonQuad(uint slot, uint quad, float x0, float y0, float angle0, float width0, float alpha0,
                   float x1, float y1, float angle1, float width1, float alpha1, bool lens, inout float4 box) {
  const float window = LensWindow * ShapeShare;
  const float side[4] = { -1.0f, 1.0f, 1.0f, -1.0f };
  const float angles[4] = { angle0, angle0, angle1, angle1 };
  const float tileSize = 1.0f / float(AtlasTiles);
  const float u = float(AtlasShapes % AtlasTiles) * tileSize + tileSize * 0.5f;
  const float v0 = float(AtlasShapes / AtlasTiles) * tileSize;
  const float nx0 = -sin(angle0) * width0 * 0.5f, ny0 = cos(angle0) * width0 * 0.5f;
  const float nx1 = -sin(angle1) * width1 * 0.5f, ny1 = cos(angle1) * width1 * 0.5f;
  const float px[4] = { x0 - nx0, x0 + nx0, x1 + nx1, x1 - nx1 };
  const float py[4] = { y0 - ny0, y0 + ny0, y1 + ny1, y1 - ny1 };
  const float acrossV[4] = { 0.0f, 1.0f, 1.0f, 0.0f };
  const float cx[4] = { x0, x0, x1, x1 };
  const float cy[4] = { y0, y0, y1, y1 };
  const float alphas[4] = { alpha0, alpha0, alpha1, alpha1 };
  const float2 fb = fbSize();

  for (uint i = 0u; i < 4u; i++) {
    QuadVertex q;
    q.pos = float2(px[i], py[i]);
    q.atlas = float2(u - (lens ? AtlasLightMarker : 0.0f), v0 + acrossV[i] * tileSize - AtlasLightMarker);
    q.scene = float2(cx[i] / fb.x + sin(angles[i]) * side[i] * window, cy[i] / fb.y - cos(angles[i]) * side[i] * window);
    q.alpha = alphas[i];
    q.redOnly = 0.0f;
    writeVertex(slot, quad, i, q);
    box = float4(min(box.xy, q.pos), max(box.zw, q.pos));
  }
  // the round ends of the band reach half a width past its ends, see compositeMain
  const float reach = max(width0, width1) * 0.5f;
  box = float4(min(box.xy, min(float2(x0, y0), float2(x1, y1)) - reach), max(box.zw, max(float2(x0, y0), float2(x1, y1)) + reach));
}

float fadeInOf(float run, float size) {
  return smooth01(clamp(run / (TrailFadeIn * max(size, 1.0f)), 0.0f, 1.0f));
}

// AddToRenderList: the quads of one drop, in the order they are drawn
void buildQuads(uint slot, Drop d) {
  float4 box = float4(1e30f, 1e30f, -1e30f, -1e30f);
  uint count = 0u;
  const bool active = d.has(kActive);
  const bool red = d.has(kBlood);

  if (active && d.has(kTrace) && d.uvIndex == AtlasShapes && ribbons()) {
    // a piece of a band of water; the first piece of a band is the point it fades in from and draws nothing
    if (d.has(kLinked)) {
      const float age = d.time;
      const float width = TrailWidthAt(age, sqrt(d.shapeX * d.shapeX + d.shapeY * d.shapeY), d.size, d.headSize);
      const float endAlpha = float(uint(d.alpha * fadeInOf(d.run, d.headSize)));
      const float before = age + d.linkAge;
      const float fade = (1.0f - clamp(before / max(d.ttl, OneUnit), 0.0f, 1.0f)) * fadeInOf(d.linkRun, d.headSize);
      const float startWidth = TrailWidthAt(before, d.linkSpeed, d.linkSize, d.linkHead);
      addRibbonQuad(slot, 0u, d.linkX, d.linkY, d.linkAngle, startWidth, float(uint(d.linkAlpha * fade)),
                    d.x, d.y, d.rotation, width, endAlpha, isLens(d), box);
      count = 1u;
    }
  } else if (active) {
    // the band of water a drop is leaving, from its last piece up to the drop, under the drop
    if (d.has(kLinked) && !d.has(kTrace) && ribbons()) {
      const float ax = d.x - d.linkX, ay = d.y - d.linkY;
      const float gap = sqrt(ax * ax + ay * ay);
      if (gap > 0.5f && !isinf(gap) && !isnan(gap)) {
        const float speed = sqrt(d.shapeX * d.shapeX + d.shapeY * d.shapeY);
        addRibbonQuad(slot, count, d.linkX, d.linkY, d.linkAngle,
                      TrailWidthAt(d.linkAge, d.linkSpeed, d.linkSize, d.linkHead),
                      float(uint(d.alpha * fadeInOf(d.linkRun, d.size))),
                      d.x, d.y, atan2(ay, ax), TrailWidthAt(0.0f, speed, RibbonSize(d), d.size),
                      float(uint(d.alpha * fadeInOf(d.linkRun + gap, d.size))), isLens(d), box);
        count++;
      }
    }
    addDropQuad(slot, count, d.x, d.y, DrawnSize(d), d.alpha, red, d.uvIndex, isLens(d), d.rotation, d.shapeX, d.shapeY, box);
    count++;
  }

  QuadsRW[uint2(slot, 0u)] = box;
  QuadsRW[uint2(slot, 1u)] = float4(float(count), d.has(kTrace) ? 1.0f : 0.0f, 0.0f, 0.0f);
}

[shader("compute")]
[numthreads(1024, 1, 1)]
void simulateMain(uint3 threadId : SV_GroupThreadID) {
  const uint tid = threadId.x;
  const float2 fb = fbSize();
  const uint pool = uint(clamp(remixFxParam(kMaxDrops), 100.0f, float(kPool)));

  // the frame time of the game, or of the runtime when no game hands one over
  const float gameStep = remixFxParam(kGameTimestep);
  const float timestep = gameStep >= 0.0f ? gameStep : remixFxFrame.deltaTimeSeconds;
  const float frameSeconds = (timestep > 0.0f && !isinf(timestep)) ? min(timestep, 0.1f) : 0.0f;

  const float4 s0 = StateRW[uint2(0u, 0u)]; // spawn remainder, blood seen, splash seen, 1 once used
  const float4 s1 = StateRW[uint2(1u, 0u)]; // last forward (scaled), 1 when there is one
  const float4 s2 = StateRW[uint2(2u, 0u)]; // air, push share
  const float4 s3 = StateRW[uint2(3u, 0u)]; // look air, travel air
  const float4 s4 = StateRW[uint2(4u, 0u)]; // landing places left, frame width, height
  const float4 s5 = StateRW[uint2(5u, 0u)]; // last position, 1 when there is one

  if (tid == 0u) {
    gsFreeCount = 0u;
    gsTraceCount = 0u;
    gsHeads = 0u;
    gsSpawnCount = 0u;
    gsUsedFree = 0u;
    gsEvicted = 0u;
    gsDeposits = 0u;
    gsReset = (remixFxFrame.historyInvalid != 0u || s0.w < 0.5f || s4.y != fb.x || s4.z != fb.y) ? 1u : 0u;
  }
  for (uint w = tid; w < kPool / 2u; w += kThreads) {
    gsFree[w] = 0u;
    gsTraces[w] = 0u;
  }
  GroupMemoryBarrierWithGroupSync();
  const bool reset = gsReset != 0u;

  // ---- Reset / Clear: the frame changed, the effect was switched on
  if (reset) {
    for (uint k = 0u; k < kPerThread; k++) {
      DropsRW[uint2(tid + k * kThreads, 1u)] = float4(0.0f, 0.0f, 0.0f, 0.0f);
    }
  }
  AllMemoryBarrierWithGroupSync();

  // ---- the pool: free places, the water of trails, the drops
  for (uint k = 0u; k < kPerThread; k++) {
    const uint slot = tid + k * kThreads;
    if (slot >= pool) {
      continue;
    }
    const uint flags = uint(DropsRW[uint2(slot, 1u)].z + 0.5f);
    if ((flags & kActive) == 0u) {
      uint index = 0u;
      InterlockedAdd(gsFreeCount, 1u, index);
      InterlockedOr(gsFree[index >> 1u], slot << ((index & 1u) * 16u));
    } else if ((flags & kTrace) != 0u) {
      uint index = 0u;
      InterlockedAdd(gsTraceCount, 1u, index);
      InterlockedOr(gsTraces[index >> 1u], slot << ((index & 1u) * 16u));
    } else {
      InterlockedAdd(gsHeads, 1u);
    }
  }
  GroupMemoryBarrierWithGroupSync();

  // ---- CalculateMovement: the air over the lens (every thread works it out alike)
  const Camera cam = currentCamera();
  const float adjust = remixFxParam(kSpeedAdjuster);
  const float3 screenRight = cam.screenRight * adjust;
  const float3 upAxis = cam.up * adjust;
  const float3 fwd = cam.fwd * adjust;
  float3 air = reset ? float3(0.0f, 0.0f, 0.0f) : s2.xyz;
  float pushShare = reset ? 0.0f : s2.w;
  float2 lookAir = reset ? float2(0.0f, 0.0f) : s3.xy;
  float2 travelAir = reset ? float2(0.0f, 0.0f) : s3.zw;
  const bool haveLastFwd = !reset && s1.w > 0.5f;
  const float3 lastPos = (!reset && s5.w > 0.5f) ? s5.xyz : float3(0.0f, 0.0f, 0.0f);
  {
    const float3 posDelta = cam.pos - lastPos;
    const float dt = frameSeconds;
    if (dt > 0.0f) {
      const float side = dot(screenRight, posDelta) / dt;
      const float lift = dot(upAxis, posDelta) / dt;
      const float forward = dot(fwd, posDelta) / dt;
      const float travel = sqrt(side * side + lift * lift + forward * forward);
      const bool cut = !(travel < CutSpeed);
      const float facing = travel > 0.001f ? (forward / travel + 1.0f) * 0.5f : 1.0f;
      const float across = travel > 0.001f ? clamp(forward / travel + 1.0f, 0.0f, 1.0f) : 1.0f;

      float airX = -side * across;
      float airY = -lift * across;
      float airZ = -forward * facing;
      {
        const float travelAirLen = cut ? 0.0f : sqrt(airX * airX + airY * airY + airZ * airZ);
        const float t = clamp((travelAirLen - PushStartSpeed) / (PushFullSpeed - PushStartSpeed), 0.0f, 1.0f);
        pushShare = (isnan(t) || isinf(t)) ? 0.0f : smooth01(t);
      }

      float lookX = 0.0f;
      float lookY = 0.0f;
      float travelX = airX;
      float travelY = airY;
      if (haveLastFwd) {
        const float3 turned = fwd - s1.xyz;
        const float yaw = dot(turned, screenRight);
        const float pitch = dot(turned, upAxis);
        const float driving = clamp((abs(forward) - LookFadeStart) / (LookFadeEnd - LookFadeStart), 0.0f, 1.0f);
        lookX = clamp(yaw * LookArm / dt * (1.0f - driving), -LookAirMax, LookAirMax);
        lookY = clamp(-pitch * LookArm / dt * (1.0f - driving), -LookAirMax, LookAirMax);
        if (sqrt(yaw * yaw + pitch * pitch) > CutTurn) {
          lookX = 0.0f;
          lookY = 0.0f;
        }
        travelX = airX;
        travelY = airY;
        if (abs(lookX) > abs(airX)) { airX = lookX; } else { lookX = 0.0f; }
        if (abs(lookY) > abs(airY)) { airY = lookY; } else { lookY = 0.0f; }
      }
      if (cut) {
        airX = 0.0f; airY = 0.0f; airZ = 0.0f;
        lookX = 0.0f; lookY = 0.0f;
        travelX = 0.0f; travelY = 0.0f;
      }
      air = float3(airX, airY, airZ);
      lookAir = float2(lookX, lookY);
      travelAir = float2(travelX, travelY);
      if (any(isnan(air)) || any(isinf(air))) { air = float3(0.0f, 0.0f, 0.0f); }
      if (any(isnan(lookAir)) || any(isinf(lookAir))) { lookAir = float2(0.0f, 0.0f); }
      if (any(isnan(travelAir)) || any(isinf(travelAir))) { travelAir = float2(0.0f, 0.0f); }
    }
  }

  // ---- the drops that land this frame (one thread: the landing table is dealt out in order)
  if (tid == 0u) {
    Random rnd = makeRandom(0xC0FFEEu);
    float spawnRemainder = reset ? 0.0f : s0.x;
    float landingLeft = reset ? 0.0f : s4.x;
    uint heads = gsHeads;
    uint available = gsFreeCount + gsTraceCount;
    uint spawns = 0u;

    const float smallest = SC(remixFxParam(kMinSize));
    const float biggest = max(SC(remixFxParam(kMaxSize)), smallest);
    const float smallTop = smallest + (biggest - smallest) * 0.32f;
    const float bigBottom = smallest + (biggest - smallest) * 0.62f;
    const float landingPush = CenterPush * pushShare;

    // SpawnDrops of a batch: kind 0 water, 1 weather, 2 blood
    for (uint batch = 0u; batch < 4u; batch++) {
      int n = 0;
      uint kind = 0u;
      if (batch == 0u) {
        // FillScreenMoving(50, true) of every hit of blood since the last frame
        const float hits = max(remixFxParam(kGameBlood) - (reset ? remixFxParam(kGameBlood) : s0.y), 0.0f);
        const float amount = 50.0f * remixFxParam(kBloodAmount);
        if (remixFxParamBool(kBloodDrops) && amount > 0.0f) {
          n = int(min(hits, 8.0f)) * int(amount * 20.0f);
        }
        kind = 2u;
      } else if (batch == 1u) {
        // FillScreenMoving of the water on the camera: the drops it stands for
        n = int(clamp(remixFxParam(kGameSplash) - (reset ? remixFxParam(kGameSplash) : s0.z), 0.0f, 4096.0f));
        kind = 0u;
      } else if (batch == 2u) {
        // FillScreenMovingRate of a spray: amount * 20 drops in a sixtieth of a second
        const float amount = remixFxParam(kGameSpray);
        if (amount > 0.0f && frameSeconds > 0.0f) {
          const float perFrame = amount * 20.0f;
          spawnRemainder = min(spawnRemainder + perFrame * frameSeconds * 60.0f, perFrame * 4.0f + 1.0f);
          if (spawnRemainder >= 1.0f) {
            n = int(floor(spawnRemainder));
            spawnRemainder -= floor(spawnRemainder);
          }
        }
        kind = 0u;
      } else {
        // SprayDrops: the rain of the weather
        const float rain = remixFxParamBool(kForceRain) ? 1.0f : clamp(remixFxParam(kGameRain), 0.0f, 1.0f);
        const float intensity = (remixFxParam(kGameRain) > 0.0f || remixFxParamBool(kForceRain)) ? RainCurve(rain) : 0.0f;
        if (intensity > 0.0f && frameSeconds > 0.0f) {
          const float landing = remixFxParamBool(kFixedPlacement) ? LandingShareOf(landingPush) : 1.0f;
          const float perFrame = WeatherDropsPerSecond / 60.0f * intensity / landing;
          spawnRemainder = min(spawnRemainder + perFrame * frameSeconds * 60.0f, perFrame * 4.0f + 1.0f);
          if (spawnRemainder >= 1.0f) {
            n = int(floor(spawnRemainder));
            spawnRemainder -= floor(spawnRemainder);
          }
        }
        kind = 1u;
      }

      // RoomForNewDrops
      const int room = int(pool) - int(heads) - 1;
      n = min(n, room);

      for (int i = 0; i < n; i++) {
        float x = rnd.next(fb.x);
        float y = rnd.next(fb.y);

        if (kind == 1u && remixFxParamBool(kFixedPlacement)) {
          // NextLandingPlace: the table, turned by a random angle, scaled up, the points on the picture, shuffled
          if (landingLeft < 0.5f) {
            const float angle = rnd.next(TwoPi) - Pi;
            const float c = cos(angle);
            const float s = sin(angle);
            uint kept = 0u;
            for (uint p = 0u; p < kLandingPointCount; p++) {
              const float2 lp = kLandingPoints[p];
              const float lx = (c * lp.x - s * lp.y) * LandingScale;
              const float ly = (s * lp.x + c * lp.y) * LandingScale;
              if (lx > -1.0f && lx < 1.0f && ly > -1.0f && ly < 1.0f) {
                LandingRW[uint2(kept, 0u)] = float2(lx, ly);
                kept++;
              }
            }
            for (uint p = kept; p > 1u; p--) {
              const uint j = min(uint(rnd.next(float(p))), p - 1u);
              const float2 a = LandingRW[uint2(p - 1u, 0u)];
              LandingRW[uint2(p - 1u, 0u)] = LandingRW[uint2(j, 0u)];
              LandingRW[uint2(j, 0u)] = a;
            }
            landingLeft = float(kept);
          }
          if (landingLeft < 0.5f) {
            continue;
          }
          landingLeft -= 1.0f;
          float2 n2 = LandingRW[uint2(uint(landingLeft), 0u)];
          const float r = length(n2);
          if (r > 0.0f && rnd.next(1.0f) > CenterPushSkip) {
            n2 += n2 / r * landingPush;
          }
          if (!(n2.x > -1.0f && n2.x < 1.0f && n2.y > -1.0f && n2.y < 1.0f)) {
            continue;
          }
          x = (n2.x + 1.0f) * 0.5f * fb.x;
          y = (1.0f - n2.y) * 0.5f * fb.y;
        }

        const bool big = rnd.next(1.0f) < BigDropShare;
        const float size = big ? bigBottom + rnd.next(biggest - bigBottom) : smallest + rnd.next(smallTop - smallest);
        float ttl = LifeMinSeconds;
        if (kind == 2u) {
          ttl = BloodHoldSeconds + rnd.next(BloodHoldSpread) + BloodFadeSeconds;
        }

        // PlaceNew: a free place, or the water of a trail; nothing when the pool is all drops
        if (available == 0u || spawns >= kMaxSpawns) {
          continue;
        }
        available--;
        gsSpawn[spawns] = float4(x, y, size, kind == 2u ? -ttl : ttl);
        spawns++;
        heads++;
      }
    }

    gsSpawnCount = spawns;
    gsUsedFree = min(spawns, gsFreeCount);
    gsEvicted = spawns > gsFreeCount ? spawns - gsFreeCount : 0u;
    gsNumDrops = heads + gsTraceCount - gsEvicted;

    StateRW[uint2(0u, 0u)] = float4(spawnRemainder, remixFxParam(kGameBlood), remixFxParam(kGameSplash), 1.0f);
    StateRW[uint2(4u, 0u)] = float4(landingLeft, fb.x, fb.y, 0.0f);
  }
  AllMemoryBarrierWithGroupSync();

  // ---- the new drops take their places
  for (uint k = tid; k < gsSpawnCount; k += kThreads) {
    const float4 s = gsSpawn[k];
    Random rnd = makeRandom(0xA5A5u + k);
    const bool blood = s.w < 0.0f;
    storeDrop(spawnSlot(k), placeNew(s.x, s.y, s.z, abs(s.w), false, blood, rnd));
  }
  AllMemoryBarrierWithGroupSync();

  // ---- ProcessMoving: MoveDrop of every drop that moves
  const uint traceReserve = max(64u, uint(float(pool) * PoolReserveShare));
  const uint tracesNow = gsTraceCount - gsEvicted;
  const uint traceRoom = (pool > traceReserve && pool - traceReserve > tracesNow) ? pool - traceReserve - tracesNow : 0u;
  const uint freeLeft = gsFreeCount - gsUsedFree;
  const uint depositRoom = min(traceRoom, freeLeft);
  const float elapsed = timestep;

  if (elapsed > 0.0f && !isinf(elapsed)) {
    const float dt = min(elapsed, 0.1f);
    const float settle = exp(-dt / LookSettle);
    const float halfW = fb.x * 0.5f;
    const float halfH = fb.y * 0.5f;
    const float maxSizePx = SC(remixFxParam(kMaxSize));
    const float minSizePx = SC(remixFxParam(kMinSize));

    for (uint k = 0u; k < kPerThread; k++) {
      const uint slot = tid + k * kThreads;
      if (slot >= pool) {
        continue;
      }
      Drop d = loadDrop(slot);
      if (!d.has(kActive) || !d.has(kMoving) || d.has(kTrace)) {
        continue;
      }

      const float px = (d.x - halfW) / halfW;
      const float py = (halfH - d.y) / halfH;
      const float kMag = d.size * 0.5f / halfH * SizeToMagnitude;
      const float simDt = dt / LifeMinSeconds;

      const float r = sqrt(px * px + py * py);
      const float outX = r > 0.0001f ? px / r : 0.0f;
      const float outY = r > 0.0001f ? py / r : 0.0f;

      const bool shoved0 = d.has(kShoved);
      const float ch = shoved0 ? cos(d.heading) : 1.0f;
      const float sh = shoved0 ? sin(d.heading) : 0.0f;
      const float slip = shoved0 ? Slip(d, d.slip) : 1.0f;
      float sideX = LensLateralGain * (d.vel.x * ch - d.vel.y * sh) * slip;
      float sideY = LensLateralGain * (d.vel.x * sh + d.vel.y * ch) * slip;
      if (remixFxParamBool(kGravity) && shoved0) {
        sideY -= LookSag * sqrt(sideX * sideX + sideY * sideY);
      }
      const float runX = sideX - LensRadialGain * d.vel.z * outX;
      const float runY = sideY - LensRadialGain * d.vel.z * outY;

      // the friction of the glass, which never turns a velocity round
      float3 vel = d.vel;
      const float friction = kMag * simDt;
      vel.x = vel.x > 0.0f ? max(0.0f, vel.x - friction) : (vel.x < 0.0f ? min(0.0f, vel.x + friction) : 0.0f);
      vel.y = vel.y > 0.0f ? max(0.0f, vel.y - friction) : (vel.y < 0.0f ? min(0.0f, vel.y + friction) : 0.0f);
      vel.z = vel.z > 0.0f ? max(0.0f, vel.z - friction) : (vel.z < 0.0f ? min(0.0f, vel.z + friction) : 0.0f);

      float3 dropAir = air;
      const float rel = clamp(d.size / max(1.0f, maxSizePx), 0.1f, 1.0f);
      bool swung = false;
      if (lookAir.x != 0.0f || lookAir.y != 0.0f) {
        const float lookX = lookAir.x != 0.0f ? air.x : 0.0f;
        const float lookY = lookAir.y != 0.0f ? air.y : 0.0f;
        const float look = sqrt(lookX * lookX + lookY * lookY);
        const float hold = LookGrip * d.grip / rel;
        const float share = look > 0.0f ? look * look / (look * look + hold * hold) : 0.0f;
        const float left = look * share;
        if (lookAir.x != 0.0f) {
          dropAir.x = abs(lookX * share) > abs(travelAir.x) ? lookX * share : travelAir.x;
        }
        if (lookAir.y != 0.0f) {
          dropAir.y = abs(lookY * share) > abs(travelAir.y) ? lookY * share : travelAir.y;
        }
        swung = left > 0.0f && (dropAir.x == lookX * share || dropAir.y == lookY * share);
      }

      const float push = LensAlignment(px, py, dropAir) * kMag * simDt;
      vel += dropAir * push;

      const float holdBack = pow(settle, d.grip / (0.6f + 0.8f * rel));
      if (!swung && abs(dropAir.x) < SettleBelow) { vel.x *= holdBack; }
      if (!swung && abs(dropAir.y) < SettleBelow) { vel.y *= holdBack; }
      d.vel = vel;

      if (swung) {
        d.set(kShoved, true);
      } else if (abs(dropAir.x) >= SettleBelow || abs(dropAir.y) >= SettleBelow || abs(vel.x) + abs(vel.y) < 1e-3f) {
        d.set(kShoved, false);
      }

      if (remixFxParamBool(kGravity) && d.fallTop > 0.0f) {
        d.fall = min(d.fallTop, d.fall + d.fallTop / GravityRise * dt);
      } else {
        d.fall = 0.0f;
      }

      float travelX = runX * halfW * simDt;
      float travelY = -runY * halfH * simDt + d.fall * dt;

      const float sideways = LensLateralGain * sqrt(vel.x * vel.x + vel.y * vel.y) * halfH / LifeMinSeconds;
      const bool shovedWater = d.has(kShoved) && sideways > ShovedTrailSpeed * Scale() && d.size > TrailSmallest * minSizePx;
      const bool leaves = shovedWater || (d.has(kTrail) && (sideways > TrailSpeed * Scale() || d.fall > 0.0f)) || d.has(kLinked);
      d.linkAge += dt;

      const float run = sqrt(travelX * travelX + travelY * travelY);
      if (leaves && run > 0.0001f && !isinf(run) && !isnan(run)) {
        const float before = Meander(d, d.meander);
        d.meander += run;
        const float aside = Meander(d, d.meander) - before;
        const float alongX = travelX / run;
        const float alongY = travelY / run;
        travelX -= alongY * aside;
        travelY += alongX * aside;
      }

      d.shapeX = travelX / dt;
      d.shapeY = travelY / dt;

      const float distance = sqrt(travelX * travelX + travelY * travelY);
      const float footprint = ribbons() ? max(2.0f * Scale(), d.size * 0.15f) : max(minSizePx, d.size * TraceShare) * 0.4f;
      const float moveStep = remixFxParam(kMoveStep);
      const float spacing = max((isinf(moveStep) || isnan(moveStep)) ? 0.1f : moveStep, max(0.25f, footprint));

      if (distance > 0.0001f && !isinf(distance) && !isnan(distance)) {
        const float remainder = fmod(d.dist, spacing);
        const float total = remainder + distance;
        const float crossed = floor(total / spacing);
        const int count = int(min(crossed, 8.0f));
        if (leaves && d.alpha > 0.0f && gsNumDrops < pool - 1u) {
          for (int i = 0; i < count; i++) {
            const float stepAlong = crossed > 8.0f ? (float(i) + 0.5f) * distance / float(count) : spacing - remainder + float(i) * spacing;
            const float t = clamp(stepAlong / distance, 0.0f, 1.0f);
            const float tx = d.x + travelX * t;
            const float ty = d.y + travelY * t;

            // NewTrace: a place in the pool for the water, or the band breaks here
            uint ticket = 0u;
            InterlockedAdd(gsDeposits, 1u, ticket);
            if (ticket >= depositRoom) {
              d.set(kLinked, false);
              continue;
            }
            const uint index = gsUsedFree + ticket;
            const uint traceSlot = readList16(gsFree[index >> 1u], index);
            InterlockedAdd(gsNumDrops, 1u);

            const bool ribbon = ribbons();
            const float traceSize = ribbon ? RibbonSize(d) : max(minSizePx, d.size * TraceShare);
            const float leftLife = max(d.ttl - d.time, OneUnit);
            Random rnd = makeRandom(0x7000u + traceSlot);
            Drop tr = placeNew(tx, ty, traceSize, min(d.traceTtl, leftLife), true, false, rnd);
            tr.alpha = d.alpha;
            tr.alpha0 = d.alpha;
            tr.shapeX = d.shapeX;
            tr.shapeY = d.shapeY;
            tr.headSize = d.size;

            if (ribbon) {
              tr.uvIndex = AtlasShapes;
              tr.rotation = atan2(d.shapeY, d.shapeX);
              const float ax = tx - d.linkX;
              const float ay = ty - d.linkY;
              const float way = ax * ax + ay * ay > 1e-6f ? atan2(ay, ax) : d.linkAngle;
              const float turned = abs(remainderTwoPi(way - d.linkAngle));
              if (d.has(kLinked) && turned > TrailSharpTurn) {
                d.set(kLinked, false);
              }
              tr.set(kLinked, d.has(kLinked));
              if (d.has(kLinked)) {
                tr.rotation = way;
                tr.linkX = d.linkX;
                tr.linkY = d.linkY;
                tr.linkAngle = d.linkAngle;
                tr.linkAge = d.linkAge;
                tr.linkSpeed = d.linkSpeed;
                tr.linkSize = d.linkSize;
                tr.linkHead = d.linkHead;
                tr.linkAlpha = d.linkAlpha;
                tr.linkRun = d.linkRun;
                tr.run = d.linkRun + sqrt(ax * ax + ay * ay);
              } else {
                tr.run = 0.0f;
                tr.linkRun = 0.0f;
              }
              d.set(kLinked, true);
              d.linkX = tx;
              d.linkY = ty;
              d.linkAngle = tr.rotation;
              d.linkAge = 0.0f;
              d.linkSpeed = sqrt(d.shapeX * d.shapeX + d.shapeY * d.shapeY);
              d.linkSize = tr.size;
              d.linkHead = tr.headSize;
              d.linkAlpha = tr.alpha0;
              d.linkRun = tr.run;
            } else {
              tr.uvIndex = d.uvIndex;
              tr.rotation = d.rotation;
            }
            storeDrop(traceSlot, tr);
          }
        }
        d.dist = fmod(total, spacing);
      }

      if (leaves && distance > 0.0f && !isinf(distance) && !isnan(distance)) {
        const float smallestTrail = TrailSmallest * minSizePx;
        d.size = max(smallestTrail, d.size - distance * TrailDrain);
        if (d.size <= smallestTrail) {
          d.set(kTrail, false);
          d.fallTop = 0.0f;
        }
      }

      d.x += travelX;
      d.y += travelY;
      if (!isinf(distance) && !isnan(distance)) {
        d.slip += distance;
      }

      if (d.x < 0.0f || d.y < 0.0f || d.x > fb.x || d.y > fb.y || isnan(d.x) || isnan(d.y)) {
        d.flags = 0u; // Expire
      }
      storeDrop(slot, d);
    }
  }
  AllMemoryBarrierWithGroupSync();

  // ---- Fade, then the quads of what is left
  for (uint k = 0u; k < kPerThread; k++) {
    const uint slot = tid + k * kThreads;
    Drop d = loadDrop(slot);
    if (slot >= pool && d.has(kActive)) {
      d.flags = 0u;
      storeDrop(slot, d);
    }
    if (d.has(kActive)) {
      d.time += max(timestep, 0.0f);
      if (d.time >= d.ttl) {
        d.flags = 0u;
      } else if (d.has(kBlood)) {
        d.alpha = float(uint(d.alpha0 * clamp((d.ttl - d.time) / BloodFadeSeconds, 0.0f, 1.0f)));
      } else {
        d.alpha = float(uint(d.alpha0 * (1.0f - clamp(d.time / d.ttl, 0.0f, 1.0f))));
      }
      storeDrop(slot, d);
    }
    buildQuads(slot, d);
  }

  if (tid == 0u) {
    StateRW[uint2(1u, 0u)] = float4(fwd, 1.0f);
    StateRW[uint2(2u, 0u)] = float4(air, pushShare);
    StateRW[uint2(3u, 0u)] = float4(lookAir, travelAir);
    StateRW[uint2(5u, 0u)] = float4(cam.pos, 1.0f);
  }
}

// ---------------------------------------------------------------------------
// the chain of the copy of the frame (D3DUSAGE_AUTOGENMIPMAP): every level the
// average of the one above it

[shader("compute")]
[numthreads(8, 8, 1)]
void mip1Main(uint2 p : SV_DispatchThreadID) {
  uint w, h;
  Mip1RW.GetDimensions(w, h);
  if (p.x >= w || p.y >= h) { return; }
  Mip1RW[p] = float4(InputColor.SampleLevel((float2(p) + 0.5f) / float2(w, h), 0.0f).rgb, 1.0f);
}

#define REMIXFX_MIP_PASS(NAME, SRC, DST) \
  [shader("compute")] \
  [numthreads(8, 8, 1)] \
  void NAME(uint2 p : SV_DispatchThreadID) { \
    uint w, h; \
    DST.GetDimensions(w, h); \
    if (p.x >= w || p.y >= h) { return; } \
    DST[p] = float4(SRC.SampleLevel(RemixFxSceneLinearSampler, (float2(p) + 0.5f) / float2(w, h), 0.0f).rgb, 1.0f); \
  }

REMIXFX_MIP_PASS(mip2Main, Mip1, Mip2RW)
REMIXFX_MIP_PASS(mip3Main, Mip2, Mip3RW)
REMIXFX_MIP_PASS(mip4Main, Mip3, Mip4RW)
REMIXFX_MIP_PASS(mip5Main, Mip4, Mip5RW)
REMIXFX_MIP_PASS(mip6Main, Mip5, Mip6RW)
REMIXFX_MIP_PASS(mip7Main, Mip6, Mip7RW)
REMIXFX_MIP_PASS(mip8Main, Mip7, Mip8RW)

float3 sceneLevel(float2 uv, int level) {
  switch (level) {
    case 0: return InputColor.SampleLevel(uv, 0.0f).rgb;
    case 1: return Mip1.SampleLevel(RemixFxSceneLinearSampler, uv, 0.0f).rgb;
    case 2: return Mip2.SampleLevel(RemixFxSceneLinearSampler, uv, 0.0f).rgb;
    case 3: return Mip3.SampleLevel(RemixFxSceneLinearSampler, uv, 0.0f).rgb;
    case 4: return Mip4.SampleLevel(RemixFxSceneLinearSampler, uv, 0.0f).rgb;
    case 5: return Mip5.SampleLevel(RemixFxSceneLinearSampler, uv, 0.0f).rgb;
    case 6: return Mip6.SampleLevel(RemixFxSceneLinearSampler, uv, 0.0f).rgb;
    case 7: return Mip7.SampleLevel(RemixFxSceneLinearSampler, uv, 0.0f).rgb;
    default: return Mip8.SampleLevel(RemixFxSceneLinearSampler, uv, 0.0f).rgb;
  }
}

// tex2Dlod of the copy of the frame: trilinear through the chain, clamped to the edge
float3 sceneLod(float2 uv, float level) {
  uv = saturate(uv);
  level = clamp(level, 0.0f, 8.0f);
  const int l0 = int(floor(level));
  const float f = level - float(l0);
  const float3 a = sceneLevel(uv, l0);
  if (f <= 0.0f || l0 >= 8) {
    return a;
  }
  return lerp(a, sceneLevel(uv, l0 + 1), f);
}

// ---------------------------------------------------------------------------
// the light field (source/shaders/d3d9/light.hlsl): an eighth of the target

void GatherTap(float2 uv, float falloff, inout float3 energy, inout float3 plain, inout float weight, inout float falloffSum) {
  falloff *= step(0.0f, uv.x) * step(uv.x, 1.0f) * step(0.0f, uv.y) * step(uv.y, 1.0f);
  falloffSum += falloff;
  const float3 source = InputColor.SampleLevel(saturate(uv), 0.0f).rgb;
  const float brightness = max(source.r, max(source.g, source.b));
  const float saturation = (brightness - min(source.r, min(source.g, source.b))) / max(brightness, 0.001f);
  const float w = brightness * brightness * (1.0f + saturation) * falloff;
  energy += source * w;
  plain += source * falloff;
  weight += w;
}

[shader("compute")]
[numthreads(8, 8, 1)]
void lightMain(uint2 p : SV_DispatchThreadID) {
  uint lw, lh;
  LightFieldRW.GetDimensions(lw, lh);
  if (p.x >= lw || p.y >= lh) { return; }
  const float2 field = float2(1.0f / float(lw), 1.0f / float(lh));
  const float2 lightUV = (float2(p) + 0.5f) * field;
  const float2 radius = float2(LightRadius * field.x / field.y, LightRadius);
  const float2 cell = radius / float(LightCellCount);
  const float2 anchor = floor(lightUV / cell) * cell;

  float3 energy = float3(0.0f, 0.0f, 0.0f);
  float3 plain = float3(0.0f, 0.0f, 0.0f);
  float weight = 0.0f;
  float falloffSum = 0.0f;
  for (int y = -LightCellCount; y <= LightCellCount; ++y) {
    for (int x = -LightCellCount; x <= LightCellCount; ++x) {
      const float2 corner = anchor + float2(float(x), float(y)) * cell;
      const float2 offset = (corner - lightUV) / radius;
      const float distance2 = dot(offset, offset);
      const float falloff = exp2(-2.0f * distance2) * (1.0f - smoothstep(0.75f, 1.0f, distance2));
      GatherTap(corner + float2(-0.25f, -0.25f) * cell, falloff, energy, plain, weight, falloffSum);
      GatherTap(corner + float2( 0.25f, -0.25f) * cell, falloff, energy, plain, weight, falloffSum);
      GatherTap(corner + float2(-0.25f,  0.25f) * cell, falloff, energy, plain, weight, falloffSum);
      GatherTap(corner + float2( 0.25f,  0.25f) * cell, falloff, energy, plain, weight, falloffSum);
    }
  }
  const float3 gathered = energy / (weight + 0.5f);
  const float3 average = plain / max(falloffSum, 0.001f);
  // the field is a target of A8R8G8B8
  const float3 field3 = saturate(max(gathered - average * 1.25f, 0.0f));

  // carried over from the frames before, see lightSteadiness: not after a cut, nor when the field starts over
  const bool fresh = remixFxFrame.historyInvalid != 0u || remixFxFrame.cameraCut != 0u;
  const float keep = fresh ? 0.0f : clamp(remixFxParam(kLightSteadiness), 0.0f, 0.95f);
  const float3 before = LightFieldRW[p].rgb;
  LightFieldRW[p] = float4(lerp(field3, before, keep), 1.0f);
}

// ---------------------------------------------------------------------------
// the tiles: which drops reach a tile of 64 pixels, in the order they are drawn
// (the water of the trails first, then the drops, each by its place in the pool)

groupshared uint gsTraceN[256];
groupshared uint gsHeadN[256];
groupshared uint gsTraceBase[256];
groupshared uint gsHeadBase[256];
groupshared uint gsTileCount;

[shader("compute")]
[numthreads(16, 16, 1)]
void binMain(uint2 groupId : SV_GroupID, uint groupIndex : SV_GroupIndex) {
  const float2 tileMin = float2(groupId * kTileSize) - 1.0f;
  const float2 tileMax = tileMin + float(kTileSize) + 2.0f;
  const uint first = groupIndex * 16u;
  uint traceMask = 0u;
  uint headMask = 0u;
  for (uint j = 0u; j < 16u; j++) {
    const uint slot = first + j;
    const float4 box = Quads.Load(int3(int(slot), 0, 0));
    const float4 info = Quads.Load(int3(int(slot), 1, 0));
    if (info.x < 0.5f || box.z < tileMin.x || box.x > tileMax.x || box.w < tileMin.y || box.y > tileMax.y) {
      continue;
    }
    if (info.y > 0.5f) { traceMask |= 1u << j; } else { headMask |= 1u << j; }
  }
  gsTraceN[groupIndex] = countbits(traceMask);
  gsHeadN[groupIndex] = countbits(headMask);
  GroupMemoryBarrierWithGroupSync();

  if (groupIndex == 0u) {
    uint t = 0u;
    for (uint i = 0u; i < 256u; i++) { gsTraceBase[i] = t; t += gsTraceN[i]; }
    uint h = t;
    for (uint i = 0u; i < 256u; i++) { gsHeadBase[i] = h; h += gsHeadN[i]; }
    gsTileCount = min(h, kTileEntries);
  }
  GroupMemoryBarrierWithGroupSync();

  const uint2 base = groupId * 16u;
  uint t = gsTraceBase[groupIndex];
  uint h = gsHeadBase[groupIndex];
  for (uint j = 0u; j < 16u; j++) {
    if (((traceMask >> j) & 1u) != 0u) {
      if (t < kTileEntries) { BinsRW[base + uint2((t + 1u) & 15u, (t + 1u) >> 4u)] = first + j; }
      t++;
    }
  }
  for (uint j = 0u; j < 16u; j++) {
    if (((headMask >> j) & 1u) != 0u) {
      if (h < kTileEntries) { BinsRW[base + uint2((h + 1u) & 15u, (h + 1u) >> 4u)] = first + j; }
      h++;
    }
  }
  if (groupIndex == 0u) {
    BinsRW[base] = gsTileCount;
  }
}

// ---------------------------------------------------------------------------
// the pixel shader of the drops (source/shaders/d3d9/drops.hlsl)

float HeightAt(float2 at, float2 lo, float2 hi) {
  const float inside = all(at >= lo) && all(at <= hi) ? 1.0f : 0.0f;
  const float a = Mask.SampleLevel(clamp(at, lo, hi), 0.0f).a;
  return a * a * inside;
}

float3 SoftHeight(float2 at, float2 rx, float2 ry, float r, float2 lo, float2 hi) {
  const float h00 = HeightAt(at - rx - ry, lo, hi), h10 = HeightAt(at - ry, lo, hi), h20 = HeightAt(at + rx - ry, lo, hi);
  const float h01 = HeightAt(at - rx, lo, hi), h11 = HeightAt(at, lo, hi), h21 = HeightAt(at + rx, lo, hi);
  const float h02 = HeightAt(at - rx + ry, lo, hi), h12 = HeightAt(at + ry, lo, hi), h22 = HeightAt(at + rx + ry, lo, hi);
  const float h = (4.0f * h11 + 2.0f * (h10 + h01 + h21 + h12) + h00 + h20 + h02 + h22) / 16.0f;
  const float gx = ((h20 + 2.0f * h21 + h22) - (h00 + 2.0f * h01 + h02)) / (8.0f * r);
  const float gy = ((h02 + 2.0f * h12 + h22) - (h00 + 2.0f * h10 + h20)) / (8.0f * r);
  return float3(h, gx, gy);
}

float3 ToLight(float3 c) { c = min(c, 0.96f); return c / (1.0f - c); }
float3 ToValue(float3 l) { return l / (1.0f + l); }

// The band of water as one smooth body: the drop shader's film (trace) branch,
// with the place across the band and its normal taken from the distance to the
// middle line of the band rather than from the v of a twisted quad. The pieces
// of a band meet round and without seams, see compositeMain.
bool FilmPS(float alpha, float across, float2 acrossDir, float2 middle, float2 pixel, bool lens, out float4 result) {
  result = float4(0.0f, 0.0f, 0.0f, 0.0f);
  const float2 frameXY = 1.0f / fbSize();
  const float blur = saturate(remixFxParam(kDropBlur));
  const float lines = 1.0f / frameXY.y;
  const float cell = max(1.0f, blur * 4.0f * lines / 1080.0f);

  const float rim = abs(across);
  const float ridge = saturate(1.0f - rim * rim);
  float cover = cell > 1.01f ? smoothstep(0.0f, 0.45f, ridge) : smoothstep(0.01f, 0.2f, ridge);
  if (cover - 0.001f < 0.0f) {
    return false;
  }

  // stripNormal * 0.5 of drops.hlsl: across the band, by how far across it the pixel is
  const float2 normal = acrossDir * across * 0.5f;
  const float nz = sqrt(saturate(1.0f - dot(normal, normal)));
  const float k = 1.0f - 0.64f * (1.0f - nz * nz);
  const float2 bend = -(sqrt(max(k, 0.0f)) - 0.8f * nz) * normal * Refraction;
  const float2 size = 1.0f / frameXY;

  float3 backdrop;
  if (cell > 1.01f) {
    // what AddRibbonQuad hands over: the picture round the band, mirrored across it
    const float2 at = middle * frameXY - acrossDir * across * (LensWindow * ShapeShare);
    const float2 reach = float2(frameXY.x / frameXY.y, 1.0f) * (0.05f * blur);
    const float patch = log2(max(0.05f * blur * size.y * 0.5f, 1.0f)) - 1.0f;
    float3 light = 2.0f * ToLight(sceneLod(at, patch));
    [unroll] for (int r = 0; r < 8; ++r) {
      const float angle = float(r) * 0.78539816f + 0.3927f;
      light += ToLight(sceneLod(at + float2(cos(angle), sin(angle)) * reach, patch));
    }
    backdrop = ToValue(light / 10.0f);
  } else {
    backdrop = sceneLod((pixel + 0.5f) * frameXY + bend, 0.0f);
  }

  float3 lightOut = float3(0.0f, 0.0f, 0.0f);
  if (lens) {
    const float3 excess = LightField.SampleLevel(RemixFxSceneLinearSampler, (pixel + 0.5f) * frameXY, 0.0f).rgb;
    const float grey = dot(excess, float3(0.2126f, 0.7152f, 0.0722f));
    const float3 light = max(grey + (excess - grey) * 2.5f, 0.0f);
    const float lightPeak = max(light.r, max(light.g, light.b));
    lightOut = light * smoothstep(0.03f, 0.20f, lightPeak);
  }
  const float peak = max(lightOut.r, max(lightOut.g, lightOut.b)) * 1.6f;
  const float3 tint = lightOut * (1.6f * 0.8f / (0.8f + peak));
  backdrop += tint * (1.0f - backdrop);
  cover = max(cover, cover * saturate(peak * 0.5f + 0.6f));

  result = float4(backdrop, (alpha / 255.0f) * cover);
  return true;
}

// PSMain; false where it clips
bool PSMain(float4 color, float2 atlas, float2 scene, float2 pixel, float2 dx, float2 dy, float2 sceneDx, float2 sceneDy,
            out float4 result) {
  result = float4(0.0f, 0.0f, 0.0f, 0.0f);
  const float2 frameXY = 1.0f / fbSize();
  const float sceneBlur = remixFxParam(kDropBlur);

  const bool trace = atlas.y < 0.0f;
  if (trace) { atlas.y += 2.0f; }
  const bool lens = atlas.x < 0.0f;
  if (lens) { atlas.x += 2.0f; }

  const float2 tile = 1.0f / float(AtlasTiles);
  const float2 base = floor(atlas / tile) * tile;
  const float2 atlasTexel = 1.0f / 256.0f;
  const float2 lo = base + atlasTexel;
  const float2 hi = base + tile - atlasTexel;

  const float2 perPixel = float2(length(dx), length(dy)) / (tile * 0.6f);

  const float lines = 1.0f / frameXY.y;
  const float blur = saturate(sceneBlur);
  const float cell = max(1.0f, blur * 4.0f * lines / 1080.0f);

  const float3 soft = SoftHeight(atlas, dx * cell, dy * cell, cell, lo, hi);
  const float h = soft.x;
  const float2 slope = soft.yz / perPixel;
  float cover = cell > 1.01f ? smoothstep(0.0f, 0.45f, h) : smoothstep(0.01f, 0.2f, h);

  float2 normal = -0.168f * slope;
  normal *= min(1.0f, 0.5f / max(length(normal), 1e-6f));

  // the band of water: along it the u of the tile, across it the v
  const float2 strip = (atlas - base) / tile;
  const float2 stripDx = dx / tile;
  const float2 stripDy = dy / tile;
  const float stripLength = 1.0f / max(length(float2(stripDx.x, stripDy.x)), 1e-5f);
  const float stripWidth = 1.0f / max(length(float2(stripDx.y, stripDy.y)), 1e-5f);
  const float halfWidth = 0.5f * stripWidth;
  const float beyond = max(abs(strip.x - 0.5f) * stripLength - max(0.5f * stripLength - halfWidth, 0.0f), 0.0f);
  const float rim = length(float2(beyond, (strip.y - 0.5f) * stripWidth)) / max(halfWidth, 1e-3f);
  const float ridge = saturate(1.0f - rim * rim);
  float2 acrossScreen = float2(stripDx.y, stripDy.y);
  acrossScreen /= max(length(acrossScreen), 1e-6f);
  const float2 stripNormal = acrossScreen * (strip.y * 2.0f - 1.0f);
  normal = trace ? stripNormal * 0.5f : normal;
  cover = trace ? (cell > 1.01f ? smoothstep(0.0f, 0.45f, ridge) : smoothstep(0.01f, 0.2f, ridge)) : cover;

  const float nz = sqrt(saturate(1.0f - dot(normal, normal)));
  const float k = 1.0f - 0.64f * (1.0f - nz * nz);
  const float2 bend = -(sqrt(max(k, 0.0f)) - 0.8f * nz) * normal * Refraction;
  const float2 uv = (pixel + 0.5f) * frameXY + bend;

  const float2 size = 1.0f / frameXY;
  const float dropPixels = 1.0f / max(max(perPixel.x, perPixel.y), 1e-4f);
  const float2 shown = size * (cell / dropPixels) * blur;
  const float2 sx = cell > 1.01f ? float2(shown.x, 0.0f) : sceneDx * size;
  const float2 sy = cell > 1.01f ? float2(0.0f, shown.y) : sceneDy * size;
  const float l = max(log2(max(max(length(sx), length(sy)), 1.0f)) - 1.0f, 0.0f);

  if (cover - 0.001f < 0.0f) {
    return false;
  }

  float3 backdrop = float3(1.0f, 1.0f, 1.0f);
  if (cell > 1.01f) {
    // the picture round the drop, mirrored, in light
    const float2 at = scene;
    const float2 reach = float2(frameXY.x / frameXY.y, 1.0f) * (0.05f * blur);
    const float patch = log2(max(0.05f * blur * size.y * 0.5f, 1.0f)) - 1.0f;
    float3 light = 2.0f * ToLight(sceneLod(at, patch));
    [unroll] for (int r = 0; r < 8; ++r) {
      const float angle = float(r) * 0.78539816f + 0.3927f;
      light += ToLight(sceneLod(at + float2(cos(angle), sin(angle)) * reach, patch));
    }
    backdrop = ToValue(light / 10.0f);
  } else {
    backdrop = sceneLod(uv, l);
  }

  // the lights around the drop, out of the light field
  float3 lightOut = float3(0.0f, 0.0f, 0.0f);
  if (lens) {
    const float3 excess = LightField.SampleLevel(RemixFxSceneLinearSampler, (pixel + 0.5f) * frameXY, 0.0f).rgb;
    const float grey = dot(excess, float3(0.2126f, 0.7152f, 0.0722f));
    const float3 light = max(grey + (excess - grey) * 2.5f, 0.0f);
    const float lightPeak = max(light.r, max(light.g, light.b));
    lightOut = light * smoothstep(0.03f, 0.20f, lightPeak);
  }
  const float peak = max(lightOut.r, max(lightOut.g, lightOut.b)) * 1.6f;
  const float3 tint = lightOut * (1.6f * 0.8f / (0.8f + peak));
  backdrop += tint * (1.0f - backdrop);
  cover = max(cover, cover * saturate(peak * 0.5f + 0.6f));

  result = float4(backdrop * color.rgb, color.a * cover);
  return true;
}

// ---------------------------------------------------------------------------
// the drops drawn over the frame: every quad as the two triangles Direct3D 9
// draws it with (0 1 2, 0 2 3), its attributes interpolated over the triangle,
// and blended over what is there (SRCALPHA, INVSRCALPHA), in order

float edgeOf(float2 a, float2 b, float2 p) {
  return (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x);
}

float3 weightsOf(float2 a, float2 b, float2 c, float2 p, float area) {
  return float3(edgeOf(b, c, p), edgeOf(c, a, p), edgeOf(a, b, p)) / area;
}

bool inTriangle(float2 a, float2 b, float2 c, float2 p, out float3 w) {
  const float area = edgeOf(a, b, c);
  w = float3(0.0f, 0.0f, 0.0f);
  if (abs(area) < 1e-6f) {
    return false;
  }
  w = weightsOf(a, b, c, p, area);
  return all(w >= 0.0f);
}

void drawTriangle(QuadVertex a, QuadVertex b, QuadVertex c, float3 w, float2 p, inout float3 color) {
  // the derivatives of the triangle: its attributes one pixel to the right and one down
  const float area = edgeOf(a.pos, b.pos, c.pos);
  const float3 wx = weightsOf(a.pos, b.pos, c.pos, p + float2(1.0f, 0.0f), area);
  const float3 wy = weightsOf(a.pos, b.pos, c.pos, p + float2(0.0f, 1.0f), area);

  const float2 atlas = w.x * a.atlas + w.y * b.atlas + w.z * c.atlas;
  const float2 scene = w.x * a.scene + w.y * b.scene + w.z * c.scene;
  const float alpha = w.x * a.alpha + w.y * b.alpha + w.z * c.alpha;
  const float2 atlasX = wx.x * a.atlas + wx.y * b.atlas + wx.z * c.atlas;
  const float2 atlasY = wy.x * a.atlas + wy.y * b.atlas + wy.z * c.atlas;
  const float2 sceneX = wx.x * a.scene + wx.y * b.scene + wx.z * c.scene;
  const float2 sceneY = wy.x * a.scene + wy.y * b.scene + wy.z * c.scene;

  const bool red = a.redOnly > 0.5f;
  const float4 vertexColor = float4(1.0f, red ? 0.0f : 1.0f, red ? 0.0f : 1.0f, alpha / 255.0f);

  float4 result;
  if (PSMain(vertexColor, atlas, scene, p, atlasX - atlas, atlasY - atlas, sceneX - scene, sceneY - scene, result)) {
    color = lerp(color, result.rgb, saturate(result.a));
  }
}

[shader("compute")]
[numthreads(8, 8, 1)]
void compositeMain(uint2 pixel : SV_DispatchThreadID) {
  if (any(pixel >= cb.imageSize)) {
    return;
  }

  float3 color = InputColor.SampleLevel((float2(pixel) + 0.5f) * cb.invImageSize, 0.0f).rgb;

  // Direct3D 9 puts the middle of a pixel on its integer coordinate
  const float2 p = float2(pixel);
  const uint2 base = (pixel / kTileSize) * 16u;
  const uint count = min(Bins.Load(int3(int2(base), 0)), kTileEntries);

  // ---- the water of the trails: every piece of band as the stretch of the middle line it covers, with
  // round ends, so the pieces of a band run into each other without seams or folds. Where pieces overlap the
  // one the pixel is deepest in counts, so water on water is one film and not two.
  float bestDepth = 0.0f;
  float bestAlpha = 0.0f;
  float bestAcross = 0.0f;
  float2 bestDir = float2(0.0f, 0.0f);
  float2 bestMiddle = float2(0.0f, 0.0f);
  bool bestLens = false;
  for (uint e = 0u; e < count; e++) {
    const uint at = e + 1u;
    const uint slot = Bins.Load(int3(int2(base + uint2(at & 15u, at >> 4u)), 0));
    const float4 box = Quads.Load(int3(int(slot), 0, 0));
    if (p.x < box.x - 1.0f || p.x > box.z + 1.0f || p.y < box.y - 1.0f || p.y > box.w + 1.0f) {
      continue;
    }
    const uint quads = uint(Quads.Load(int3(int(slot), 1, 0)).x + 0.5f);
    for (uint q = 0u; q < quads; q++) {
      const QuadVertex v0 = readVertex(slot, q, 0u);
      if (v0.atlas.y >= 0.0f) {
        continue; // a drop, drawn below
      }
      const QuadVertex v1 = readVertex(slot, q, 1u);
      const QuadVertex v2 = readVertex(slot, q, 2u);
      const QuadVertex v3 = readVertex(slot, q, 3u);
      const float2 a = (v0.pos + v1.pos) * 0.5f;
      const float2 b = (v2.pos + v3.pos) * 0.5f;
      const float halfA = length(v1.pos - v0.pos) * 0.5f;
      const float halfB = length(v2.pos - v3.pos) * 0.5f;
      const float2 ab = b - a;
      const float len2 = dot(ab, ab);
      const float t = len2 > 1e-6f ? saturate(dot(p - a, ab) / len2) : 0.0f;
      const float2 middle = a + ab * t;
      const float half = max(lerp(halfA, halfB, t), 0.5f);
      const float2 off = p - middle;
      const float dist = length(off);
      if (dist >= half) {
        continue;
      }
      const float across = dist / half;
      const float alpha = lerp(v0.alpha, v2.alpha, t);
      const float depth = (1.0f - across * across) * alpha;
      if (depth > bestDepth) {
        bestDepth = depth;
        bestAlpha = alpha;
        // which side of the middle line the pixel is on, along the normal of the band
        const float2 n = len2 > 1e-6f ? float2(-ab.y, ab.x) / sqrt(len2) : float2(0.0f, 1.0f);
        const float side = dot(off, n) >= 0.0f ? 1.0f : -1.0f;
        bestAcross = across * side;
        bestDir = n;
        bestMiddle = middle;
        bestLens = v0.atlas.x < 0.0f;
      }
    }
  }
  if (bestDepth > 0.0f) {
    float4 film;
    if (FilmPS(bestAlpha, bestAcross, bestDir, bestMiddle, p, bestLens, film)) {
      color = lerp(color, film.rgb, saturate(film.a));
    }
  }

  // ---- the drops, in the order they are drawn
  for (uint e = 0u; e < count; e++) {
    const uint at = e + 1u;
    const uint slot = Bins.Load(int3(int2(base + uint2(at & 15u, at >> 4u)), 0));
    const float4 box = Quads.Load(int3(int(slot), 0, 0));
    if (p.x < box.x - 1.0f || p.x > box.z + 1.0f || p.y < box.y - 1.0f || p.y > box.w + 1.0f) {
      continue;
    }
    const uint quads = uint(Quads.Load(int3(int(slot), 1, 0)).x + 0.5f);
    for (uint q = 0u; q < quads; q++) {
      const QuadVertex v0 = readVertex(slot, q, 0u);
      if (v0.atlas.y < 0.0f) {
        continue; // water of a trail, drawn above
      }
      const QuadVertex v1 = readVertex(slot, q, 1u);
      const QuadVertex v2 = readVertex(slot, q, 2u);
      const QuadVertex v3 = readVertex(slot, q, 3u);
      float3 w;
      if (inTriangle(v0.pos, v1.pos, v2.pos, p, w)) {
        drawTriangle(v0, v1, v2, w, p, color);
      } else if (inTriangle(v0.pos, v2.pos, v3.pos, p, w)) {
        drawTriangle(v0, v2, v3, w, p, color);
      }
    }
  }

  OutputColor[pixel] = float4(color, 1.0f);
}
