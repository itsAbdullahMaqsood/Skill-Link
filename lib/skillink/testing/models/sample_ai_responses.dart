import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/testing/models/sample_workers.dart';

class SampleAiResponses {
  SampleAiResponses._();

  static final List<FakeQA> _pairs = [

    FakeQA(
      keywords: ['fridge', 'refrigerator', 'cooling', 'freezer'],
      response:
          'Based on your description, this sounds like a **compressor or thermostat issue**. '
          'Here are some quick DIY checks:\n\n'
          '1. Make sure the fridge isn\'t overloaded — blocked vents prevent airflow\n'
          '2. Check the condenser coils at the back for dust buildup\n'
          '3. Listen for a clicking sound — that indicates the compressor is trying to start but failing\n\n'
          'If the compressor is cycling on and off, you\'ll need a certified HVAC technician to diagnose it. '
          'I\'ve found a top-rated specialist near you.',
      suggestedTrade: 'hvac',
      recommendedWorker: SampleWorkers.all[2],
      reasonBlurb:
          'Top-rated HVAC specialist in your area with 200+ completed jobs.',
    ),

    FakeQA(
      keywords: ['ac', 'air conditioner', 'leaking', 'dripping'],
      response:
          'An AC that\'s leaking water indoors usually means one of these:\n\n'
          '- **Clogged drain line** — the most common cause. You can try flushing it with warm water.\n'
          '- **Frozen evaporator coil** — turn the AC off for 2–3 hours, then run fan-only mode.\n'
          '- **Low refrigerant** — this requires a professional to check and refill.\n\n'
          'If the leak persists after trying the drain line flush, I\'d recommend getting a technician to look at it.',
      suggestedTrade: 'hvac',
      recommendedWorker: SampleWorkers.all[2],
      reasonBlurb:
          'HVAC engineer with split AC expertise, just 4.6 km from you.',
    ),

    FakeQA(
      keywords: ['light', 'flickering', 'socket', 'electrical', 'switch'],
      response:
          'Flickering lights can be caused by:\n\n'
          '1. **Loose bulb** — try tightening it\n'
          '2. **Faulty switch** — toggle it a few times; if flickering stops, the switch contacts may be worn\n'
          '3. **Overloaded circuit** — common if the flickering happens when another appliance turns on\n'
          '4. **Loose wiring** — this is a safety hazard and needs an electrician\n\n'
          '⚠️ If multiple lights flicker at once, **do not attempt a DIY fix** — this suggests a wiring or panel issue. '
          'I\'ve matched you with a verified electrician nearby.',
      suggestedTrade: 'electrician',
      recommendedWorker: SampleWorkers.all[0],
      reasonBlurb:
          'Certified electrician with 10+ years of experience, just 1.8 km away.',
    ),

    FakeQA(
      keywords: ['washer', 'washing machine', 'noise', 'vibration', 'shaking'],
      response:
          'A washing machine making unusual noise often indicates:\n\n'
          '- **Unbalanced load** — redistribute clothes evenly\n'
          '- **Worn drum bearings** — growling/rumbling noise during spin cycle\n'
          '- **Foreign object** — check the rubber seal around the door for coins, buttons\n'
          '- **Loose drum spider** — causes banging during spin\n\n'
          'If the noise is a loud banging during spin, the drum spider or shock absorbers likely need replacing. '
          'A technician can diagnose this accurately.',
      suggestedTrade: 'electrician',
      recommendedWorker: SampleWorkers.all[4],
      reasonBlurb:
          'Handles both electrical and HVAC appliances on a single visit.',
    ),

    FakeQA(
      keywords: ['pipe', 'leak', 'water', 'tap', 'drip', 'plumbing'],
      response:
          'For a leaking pipe or tap:\n\n'
          '1. **Turn off the water supply** to that fixture immediately\n'
          '2. Place a bucket underneath to catch drips\n'
          '3. For a dripping tap, the washer inside the valve is likely worn — replacing it is a 15-minute fix if you have the right tool\n'
          '4. For pipe leaks, wrap the area tightly with plumber\'s tape as a temporary fix\n\n'
          'If the leak is from a joint or the pipe itself is corroded, you\'ll need a plumber to replace that section.',
      suggestedTrade: 'plumber',
      recommendedWorker: SampleWorkers.all[1],
      reasonBlurb:
          'Pipe-repair specialist with same-day service, 3.2 km from you.',
    ),

    FakeQA(
      keywords: ['voltage', 'power', 'outage', 'tripping', 'breaker', 'ups'],
      response:
          'Frequent breaker tripping or voltage issues could mean:\n\n'
          '- **Overloaded circuit** — unplug non-essential devices and see if it holds\n'
          '- **Short circuit** — check for burnt smell near outlets\n'
          '- **Faulty appliance** — plug appliances in one at a time to isolate the culprit\n'
          '- **Utility-side voltage fluctuation** — check with your neighbours; if it\'s widespread, contact LESCO\n\n'
          'If your breaker keeps tripping even with a reduced load, there may be a wiring fault. '
          'An electrician should inspect your panel.',
      suggestedTrade: 'electrician',
      recommendedWorker: SampleWorkers.all[0],
      reasonBlurb:
          'Specializes in load-balancing and safety upgrades — 1.8 km away.',
    ),

    FakeQA(
      keywords: ['door', 'cabinet', 'furniture', 'wood', 'hinge'],
      response:
          'For a door or cabinet that won\'t close properly:\n\n'
          '1. Check if the hinges are loose — tighten the screws\n'
          '2. If the screw holes are stripped, insert a toothpick with wood glue, let it dry, then re-drive the screw\n'
          '3. Warped wood from humidity can cause misalignment — sanding the edge may help\n'
          '4. For sliding cabinet doors, clean the track and check the rollers\n\n'
          'If the frame itself is damaged or the door needs rehung, a carpenter can sort it out quickly.',
      suggestedTrade: 'carpenter',
      recommendedWorker: SampleWorkers.all[3],
      reasonBlurb:
          'Custom furniture and repair specialist — available within your area.',
    ),


    FakeQA(
      keywords: ['smell', 'drain', 'odor', 'stink'],
      response:
          'A bad smell from the drain is usually caused by **dried-out P-trap** or food buildup:\n\n'
          '1. Pour a full kettle of boiling water down the drain\n'
          '2. Follow with ½ cup baking soda + ½ cup vinegar — let it fizz for 15 minutes\n'
          '3. Flush with hot water again\n'
          '4. If the smell is from a floor drain, pour a glass of water to refill the P-trap seal\n\n'
          'This should resolve it. If the odour persists, the vent pipe on your roof might be blocked.',
      suggestedTrade: 'plumber',
      recommendedWorker: null,
      reasonBlurb: null,
    ),

    FakeQA(
      keywords: ['wifi', 'internet', 'router', 'slow'],
      response:
          'Slow WiFi troubleshooting:\n\n'
          '1. **Restart your router** — unplug for 30 seconds, then power on\n'
          '2. Move the router to a central, elevated position away from walls and appliances\n'
          '3. Check if too many devices are connected — disconnect unused ones\n'
          '4. Run a speed test (fast.com) — if speed matches your plan, the issue is device-side\n'
          '5. Switch from 2.4 GHz to 5 GHz band for faster short-range speeds\n\n'
          'This is typically a DIY fix. If your router hardware is old (3+ years), consider upgrading.',
      suggestedTrade: null,
      recommendedWorker: null,
      reasonBlurb: null,
    ),

    FakeQA(
      keywords: ['paint', 'wall', 'crack', 'peel'],
      response:
          'For peeling paint or wall cracks:\n\n'
          '1. Scrape off loose paint with a putty knife\n'
          '2. Sand the area smooth\n'
          '3. Fill cracks with wall filler / spackling compound\n'
          '4. Let dry fully (24 hours), sand lightly, then prime and repaint\n\n'
          'For small areas, this is an easy weekend project. Use a primer before the topcoat for best adhesion.',
      suggestedTrade: null,
      recommendedWorker: null,
      reasonBlurb: null,
    ),
  ];

  static const _fallback = FakeQA(
    keywords: [],
    response:
        'I\'d be happy to help diagnose the issue! Could you provide a bit more detail?\n\n'
        '- **What appliance or area** is affected?\n'
        '- **When did it start** — suddenly or gradually?\n'
        '- **Any unusual sounds, smells, or visual signs?**\n\n'
        'The more detail you share, the better I can help troubleshoot or match you with the right technician.',
    suggestedTrade: null,
    recommendedWorker: null,
    reasonBlurb: null,
  );

  static FakeQA match(String userMessage) {
    final lower = userMessage.toLowerCase();
    for (final qa in _pairs) {
      for (final kw in qa.keywords) {
        if (lower.contains(kw)) return qa;
      }
    }
    return _fallback;
  }
}

class FakeQA {
  const FakeQA({
    required this.keywords,
    required this.response,
    required this.suggestedTrade,
    required this.recommendedWorker,
    this.reasonBlurb,
  });

  final List<String> keywords;
  final String response;
  final String? suggestedTrade;
  final Worker? recommendedWorker;
  final String? reasonBlurb;
}
