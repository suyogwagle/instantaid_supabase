const Map<String, Map<String, dynamic>> emergencyGuidelines = {
  "snake_bite": {
    "source_orgs": "WHO, HealthDirect Australia, Red Cross",
    "questions": [
      "Is the person unconscious, having trouble breathing, or bleeding heavily from the bite site?",
      "Is there swelling, fang marks, or discoloration?"
    ],
    "instructions": [
      "🚨 IMMEDIATE ACTION:",
      "1. Keep the victim calm and still.",
      "2. Immobilize the bitten limb and keep it below heart level.",
      "3. Remove rings, watches, or tight clothing from the affected limb.",
      "4. Gently clean the wound with water; do not flush with strong jets.",
      "5. Cover the wound with a clean, dry dressing.",
      "⚠️ CALL 102/103 EMERGENCY SERVICES IMMEDIATELY.",
      "❌ Do NOT cut the wound, attempt to suck out venom, or apply a tourniquet."
    ],
    "critical_instructions": [
      "🚨 CRITICAL SNAKE BITE:",
      "1. Call 102/103 emergency services immediately.",
      "2. Keep the victim completely still to slow venom spread.",
      "3. Apply a pressure immobilization bandage if trained to do so.",
      "4. Monitor airway, breathing, and circulation continuously.",
      "5. Prepare for rapid transport to hospital; note time of bite and any symptoms."
    ],
    "rules": {
      0: {"yes": "critical"},
      1: {"yes": "instructions"}
    }
  },

  "burn": {
    "source_orgs": "Red Cross, American Burn Association, WHO",
    "questions": [
      "Is the person unconscious or having trouble breathing?",
      "Are there blisters or charred (blackened) skin?",
      "Is it a small superficial burn (red skin only, no blisters)?"
    ],
    "instructions": [
      "🚨 IMMEDIATE ACTION:",
      "1. Cool the burn with running cool (not cold) water for at least 20 minutes.",
      "2. Remove tight items (rings, bracelets) before swelling begins.",
      "3. Cover the burn loosely with a sterile, non-adhesive dressing.",
      "4. Elevate the burned area if possible to reduce swelling.",
      "⚠️ Seek hospital care for severe burns, deep burns, or burns to critical areas.",
      "❌ Do NOT apply butter, oils, or ice directly to the burn."
    ],
    "critical_instructions": [
      "🚨 CRITICAL BURN:",
      "1. Call 102/103 emergency services immediately.",
      "2. Cover the burn with a clean, dry cloth or sterile dressing.",
      "3. Do not remove clothing stuck to the burn; do not immerse large burns in water if shock is suspected.",
      "4. Monitor breathing and circulation; treat for shock if signs appear.",
      "5. Arrange urgent transport to hospital for deep, extensive, or critical-area burns."
    ],
    "rules": {
      0: {"yes": "critical"},
      1: {"yes": "critical"},
      2: {"yes": "instructions"}
    }
  },

  "altitude_sickness": {
    "source_orgs": "Wilderness Medical Society (WMS), CDC",
    "questions": [
      "Is the person confused, drowsy, vomiting repeatedly, or having difficulty breathing at altitude?",
      "Do they have headache, nausea, dizziness, or breathlessness?"
    ],
    "instructions": [
      "🚨 IMMEDIATE ACTION:",
      "1. Stop ascent immediately.",
      "2. Descend 300–500 meters or more if symptoms persist.",
      "3. Administer supplemental oxygen if available.",
      "4. Keep the person warm and well hydrated.",
      "⚠️ Arrange medical evaluation if symptoms persist or worsen."
    ],
    "critical_instructions": [
      "🚨 CRITICAL ALTITUDE SICKNESS:",
      "1. Begin immediate descent regardless of altitude.",
      "2. Administer oxygen continuously if available.",
      "3. Monitor consciousness and breathing; treat for shock if needed.",
      "4. Arrange urgent evacuation to definitive medical care."
    ],
    "rules": {
      0: {"yes": "critical"},
      1: {"yes": "instructions"}
    }
  },

  "choking": {
    "source_orgs": "American Heart Association (AHA 2025), Red Cross",
    "questions": [
      "Is the person unable to breathe, speak, or cough effectively, or are they unconscious?",
      "Can the person cough, speak, or breathe?"
    ],
    "instructions": [
      "🚨 IF CONSCIOUS AND ABLE TO COUGH:",
      "1. Encourage forceful coughing; do not interfere.",
      "2. If coughing is ineffective and obstruction persists: deliver up to 5 back blows.",
      "3. If still obstructed: deliver up to 5 abdominal thrusts (Heimlich maneuver) for adults.",
      "🚨 IF UNCONSCIOUS:",
      "1. Call 102/103 emergency services immediately.",
      "2. Begin CPR and check the airway for visible obstruction before rescue breaths.",
      "⚠️ Emergency help required for persistent airway obstruction."
    ],
    "critical_instructions": [
      "🚨 CRITICAL CHOKING:",
      "1. Call 102/103 emergency services immediately.",
      "2. If trained, begin advanced airway maneuvers and CPR as indicated.",
      "3. Continue attempts to relieve obstruction until help arrives.",
      "4. Prepare for rapid transport to hospital if obstruction cannot be relieved."
    ],
    "rules": {
      0: {"yes": "critical"},
      1: {"no": "instructions"}
    }
  },

  "cardiac_attack": {
    "source_orgs": "American Heart Association (AHA), St John Ambulance, Red Cross",
    "questions": [
      "Is the person unconscious, not breathing normally, or showing signs of cardiac arrest?",
      "Is there chest pain, pressure, or shortness of breath?"
    ],
    "instructions": [
      "🚨 TIME CRITICAL:",
      "1. Call 102/103 emergency services immediately.",
      "2. Help the person sit comfortably and keep them calm.",
      "3. If not allergic and available, give aspirin (chewable) as per local guidance.",
      "4. Monitor breathing and consciousness continuously.",
      "⚠️ If the person becomes unconscious and not breathing normally, start CPR."
    ],
    "critical_instructions": [
      "🚨 CRITICAL CARDIAC EVENT:",
      "1. Call 102/103 emergency services immediately and request advanced life support.",
      "2. Begin CPR immediately if the person is unresponsive and not breathing normally.",
      "3. Use an automated external defibrillator (AED) if available and follow prompts.",
      "4. Continue CPR and defibrillation as indicated until professional help arrives."
    ],
    "rules": {
      0: {"yes": "critical"},
      1: {"yes": "instructions"}
    }
  },

  "wound": {
    "source_orgs": "Red Cross, Stop the Bleed Campaign, WHO",
    "questions": [
      "Is the bleeding uncontrolled, the person losing consciousness, or is bone/tissue exposed?",
      "Is bleeding heavy or continuous despite pressure?"
    ],
    "instructions": [
      "🚨 CONTROL BLEEDING:",
      "1. Apply firm, direct pressure to the wound with a clean dressing.",
      "2. Elevate the injured area if it does not cause further pain or injury.",
      "3. Secure a bandage firmly to maintain pressure.",
      "4. Do not remove embedded objects; stabilize them and seek urgent care.",
      "⚠️ Seek hospital care if bleeding continues, if there is deep tissue damage, or signs of shock."
    ],
    "critical_instructions": [
      "🚨 CRITICAL BLEEDING:",
      "1. Call 102/103 emergency services immediately.",
      "2. Apply continuous, firm pressure; use additional dressings if blood soaks through.",
      "3. Consider a tourniquet only if direct pressure fails and you are trained to apply it.",
      "4. Monitor for signs of shock and prepare for urgent transport."
    ],
    "rules": {
      0: {"yes": "critical"},
      1: {"yes": "instructions"}
    }
  },

  "road_accident": {
    "source_orgs": "Red Cross, ITLS (International Trauma Life Support)",
    "questions": [
      "Is anyone unconscious, not breathing, or bleeding heavily at the scene?",
      "Is there suspected neck or spine injury?"
    ],
    "instructions": [
      "🚨 SCENE SAFETY:",
      "1. Ensure scene safety before approaching; call 102/103 emergency services immediately.",
      "2. Do not move victims unless there is immediate danger.",
      "3. Check airway, breathing, and circulation; provide basic life support as needed.",
      "4. Control severe bleeding with direct pressure.",
      "⚠️ If spinal injury is suspected, immobilize the head and neck and avoid movement."
    ],
    "critical_instructions": [
      "🚨 CRITICAL ROAD TRAUMA:",
      "1. Call 102/103 emergency services immediately and request trauma response.",
      "2. Provide life-saving interventions (airway, breathing, circulation) as trained.",
      "3. Control catastrophic hemorrhage with direct pressure or tourniquet if trained.",
      "4. Avoid moving the patient if spinal injury is suspected; stabilize and await rescue."
    ],
    "rules": {
      0: {"yes": "critical"},
      1: {"yes": "instructions"}
    }
  },

  "electric_shock": {
    "source_orgs": "Red Cross, OSHA, CDC",
    "questions": [
      "Is the person unconscious, not breathing, or is the power source still live?",
      "Is the power source disconnected and person breathing normally?"
    ],
    "instructions": [
      "🚨 SAFETY FIRST:",
      "1. Turn off the power source or remove the person from the source using a non-conductive object if safe to do so.",
      "2. Do not touch the victim while the power source is live.",
      "3. Check breathing and pulse; begin CPR if required.",
      "4. Arrange urgent medical evaluation even if the person appears well.",
      "⚠️ Hospital evaluation is recommended for all significant electric shocks."
    ],
    "critical_instructions": [
      "🚨 CRITICAL ELECTRIC SHOCK:",
      "1. Call 102/103 emergency services immediately.",
      "2. If the power source is still live, do not approach until it is safe.",
      "3. Begin CPR immediately if the person is unresponsive and not breathing.",
      "4. Monitor for cardiac arrhythmias and prepare for urgent transport."
    ],
    "rules": {
      0: {"yes": "critical"},
      1: {"no": "critical"}
    }
  },

  "poisoning": {
    "source_orgs": "WHO, American Association of Poison Control Centers",
    "questions": [
      "Is the person unconscious, having seizures, or showing severe breathing difficulty after ingestion/exposure?",
      "What substance was taken (if known)?"
    ],
    "instructions": [
      "🚨 POISONING:",
      "1. Call 102/103 emergency services or local poison control immediately and follow their instructions.",
      "2. Do NOT induce vomiting unless specifically instructed by a professional.",
      "3. Keep the container or label for identification and bring it to medical personnel.",
      "4. If vomiting occurs, place the person on their side to reduce aspiration risk.",
      "⚠️ Seek emergency care for unknown substances, large ingestions, or if the person is deteriorating."
    ],
    "critical_instructions": [
      "🚨 CRITICAL POISONING:",
      "1. Call 102/103 emergency services immediately and inform them of the substance if known.",
      "2. Follow poison control instructions precisely; administer antidote only if directed.",
      "3. Support airway and breathing; begin CPR if the person is unresponsive and not breathing.",
      "4. Prepare for rapid transport to hospital with the substance container or label."
    ],
    "rules": {
      0: {"yes": "critical"},
      1: {"unknown": "instructions"}
    }
  },

  "allergic_reaction": {
    "source_orgs": "American Academy of Allergy Asthma & Immunology, Red Cross",
    "questions": [
      "Is the person having severe breathing difficulty, throat tightness, or facial swelling?",
      "Does the person have an EpiPen or prescribed epinephrine available?"
    ],
    "instructions": [
      "🚨 ANAPHYLAXIS:",
      "1. If epinephrine auto-injector is available, administer immediately as per instructions.",
      "2. Call 102/103 emergency services immediately after administering epinephrine.",
      "3. Lay the person flat and elevate the legs unless breathing is difficult.",
      "4. Monitor breathing and be prepared to start CPR if the person becomes unresponsive.",
      "⚠️ A second dose of epinephrine may be required; transport to hospital for observation."
    ],
    "critical_instructions": [
      "🚨 CRITICAL ANAPHYLAXIS:",
      "1. Call 102/103 emergency services immediately and administer epinephrine without delay if available.",
      "2. Begin CPR if the person becomes unresponsive and not breathing normally.",
      "3. Provide high-flow oxygen if available and monitor vital signs.",
      "4. Arrange urgent transport to hospital; repeat epinephrine per local guidance if symptoms persist."
    ],
    "rules": {
      0: {"yes": "critical"},
      1: {"yes": "instructions"}
    }
  },

  "fracture": {
    "source_orgs": "Red Cross, American College of Surgeons",
    "questions": [
      "Is there severe deformity, uncontrolled bleeding, or loss of circulation/sensation in the limb?",
      "Is there an obvious deformity or inability to move the limb?"
    ],
    "instructions": [
      "🚨 FRACTURE CARE:",
      "1. Immobilize the injured area in the position found using splints or padding.",
      "2. Apply a splint to support and limit movement; avoid forcing alignment.",
      "3. Apply ice packs wrapped in cloth to reduce swelling (short intervals).",
      "4. Do not attempt to realign or push protruding bone back in.",
      "⚠️ Seek hospital care for imaging and definitive management."
    ],
    "critical_instructions": [
      "🚨 CRITICAL FRACTURE:",
      "1. Call 102/103 emergency services if there is severe deformity, uncontrolled bleeding, or compromised circulation.",
      "2. Immobilize and support the limb; check distal pulses and sensation frequently.",
      "3. Treat for shock if signs appear and prepare for urgent transport."
    ],
    "rules": {
      0: {"yes": "critical"},
      1: {"yes": "instructions"}
    }
  },

  "common_cold": {
    "source_orgs": "CDC, WHO",
    "questions": [
      "Is the person having severe breathing difficulty, very high fever, or signs of severe illness?",
      "Is there fever or symptoms lasting more than 7 days?"
    ],
    "instructions": [
      "🏥 HOME CARE:",
      "1. Rest and maintain adequate fluid intake.",
      "2. Use paracetamol or other recommended antipyretics for fever and discomfort.",
      "3. Steam inhalation or saline nasal drops may relieve congestion.",
      "4. Honey can soothe cough in children older than 1 year.",
      "⚠️ See a healthcare provider if symptoms worsen, high fever develops, or symptoms persist beyond a few days."
    ],
    "critical_instructions": [
      "🚨 SEEK MEDICAL ADVICE:",
      "1. If breathing becomes difficult, oxygen saturation falls, or the person becomes very unwell, seek urgent medical care.",
      "2. Infants, elderly, or people with chronic conditions should be assessed by a clinician if symptoms worsen."
    ],
    "rules": {
      0: {"yes": "critical"},
      1: {"yes": "instructions"}
    }
  }
};
