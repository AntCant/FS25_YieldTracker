# YieldTracker 1.1.0.0.0 – Test Checklist

Manual in-game tests for the 1.1.0.0.0 rework: yield is now recorded from the harvest itself, works for any crop, and is saved by fill type name.

## Setup

1. Set `YieldTracker.debug = true` in [src/scripts/yieldTracker.lua](src/scripts/yieldTracker.lua) and rebuild the mod zip.
2. Watch `Documents\My Games\FarmingSimulator2025\log.txt` while testing. Useful log lines:
   - `Harvest hooks installed`: always printed once at startup, even with debug off. If it's missing, nothing will be recorded.
   - `Recorded <liters>L of <FILLTYPE> on farmland <id> (year <n>) by vehicle <id>`: yield recorded
   - `<liters>L of <FILLTYPE> unloaded onto farmland <id>`: material put back on the ground
   - `Picked up <liters>L previously unloaded on farmland <id>; not counted again`: double counting prevented
3. **Resetting between tests:** with debug on, open the developer console (`~`) and run `ytClearData`. All recorded data for the current save is cleared; reopen the menu to see it empty. The save file only changes on the next game save, so reloading without saving brings the old data back.
4. **Checking amounts:** start with an empty tank, harvest, and compare the total of the logged amounts with the tank's fill level.
5. Data is stored per savegame in `savegameX\yieldTrackerData.xml`.

---

## 1. Loading and saving

- [ ] **New savegame:** no Lua errors; the menu shows an empty crop list and "No Yield History".
- [ ] **Old 1.0.x save:** the history is still there, under the correct crops and fields.
- [ ] **Converted save file:** save that game and open `yieldTrackerData.xml`. Entries use `fillType="WHEAT"`-style names, and the old `prevFillLevels` block is gone.
- [ ] **Switching savegames without restarting:** load save A, quit to the menu, load save B.
  - [ ] Save B shows none of save A's data.
  - [ ] Harvest a known amount in B: it's recorded **once**, not twice. This checks the hooks didn't install twice.
- [ ] **Each save is separate:** two saves with yield data each show only their own history.
- [ ] **New game in a previously used slot:** start a new game in a slot that held an old save with yield data. The menu should be empty.
- [ ] **Removed mod crop:** with yield recorded for a mod crop, remove that mod, then load and save. Re-add the mod and load again: that crop's history is back.
- [ ] **Multiplayer:** the "YieldTracker disabled in multiplayer mode" warning still shows and nothing is recorded.

## 2. Harvesters

The logged amount should equal what goes into the tank or trailer.

- [ ] **Grain combine with a tank:** wheat, barley, oat, canola, corn, soybeans, sunflowers, sorghum.
- [ ] **Unloading while harvesting:** unload into a trailer on the move. Yield harvested during unloading is included.
- [ ] **Full tank:** recording stops when the combine stops harvesting.
- [ ] **Forage harvester into a trailer:** amounts match.
- [ ] **Switching trailers:** move the forage harvester to a half-full trailer. The recorded amount doesn't jump.
- [ ] **Forage harvester without a trailer:**
  - [ ] The first few seconds (the harvester's short buffer) are recorded and unload when a trailer arrives.
  - [ ] After that, the log shows `discarded …L (nowhere to unload); not recorded` and nothing is recorded.
  - [ ] A trailer pulls alongside: recording resumes as normal.
- [ ] **AI forage harvester without a trailer:** AI waits for a trailer instead of discarding. Nothing is lost and amounts match.
- [ ] **Forage harvester with a pickup header** on a grass windrow.
- [ ] **Root crops:** potatoes, sugar beet, carrots, red beet, parsnips.
- [ ] **Other harvesters:** sugarcane, cotton, rice, long-grain rice.
- [ ] **Special harvesters:** spinach, green beans, peas.
- [ ] **Grapes.** Most important to test: their harvest code isn't documented.
- [ ] **Olives.** Same reason.
- [ ] **AI worker** harvesting.
- [ ] **Harvest contract.**
- [ ] **Rain:** the recorded amount drops the same way the tank amount does.
- [ ] **Damaged combine:** the recorded amount drops the same way the tank amount does.
- [ ] **A modded harvester.**
- [ ] **A custom crop on a mod map:** it shows up with its own name and icon.

## 3. Balers and loader wagons

- [ ] **Square baler:** straw, hay, grass.
- [ ] **Round baler:** straw, hay, grass.
- [ ] **Non-stop baler** (with a buffer).
- [ ] **Baler and wrapper combination.**
- [ ] **Baler with additive:** the recorded amount is about 5% higher than the windrow amount.
- [ ] **Loader wagon:** grass, hay, straw.
- [ ] **Across a farmland boundary:** the amount is split between the two farmlands.
- [ ] **Off any farmland** (road or verge): nothing recorded, no errors.

## 4. Double-counting protection

- [ ] **Normal chain:** combine drops straw, then tedder or rake, then baler. Counted **once**.
- [ ] **Hay:** mower, then tedder, then baler. Counted once, as hay.
- [ ] **Loader wagon then baler:** the wagon picks up straw and dumps it, then a baler bales it. The bale isn't counted again (log: `not counted again`).
- [ ] **CutOpenBale:** cut a bale open and re-bale it. Not counted again.
- [ ] **Bought or stored straw:** tip it from a trailer and bale it. Not counted.
- [ ] **Front loader:** move a straw heap, then bale it. Not counted again.
- [ ] **Dump on another farmland:** dump straw on farmland B and bale it there. The amount is subtracted on B.
- [ ] **Heap left on a field:** leave a dumped heap on a field and bale that field's own straw first.
  - [ ] The first amount equal to the heap isn't counted.
  - [ ] The heap counts when it's baled.
  - [ ] The farmland total comes out right.
- [ ] **Save and reload with a heap waiting:** reload and bale it. Still not counted, and `returnedToGround` is present in the XML.
- [ ] **Combine unloads grain onto the ground:** nothing breaks and nothing is recorded.
- [ ] **Other heaps** (stone, lime, gravel, map productions, HeapDelivery orders): no `unloaded onto farmland` log lines.
- [ ] **New baler or loader wagon:** buy one that accepts an unusual fill type. Within about 10 s, dumping that fill type is tracked.

## 5. Field attribution

- [ ] **Field edge:** harvest along an edge between two farmlands. Yield goes to the farmland under the header.
- [ ] **Wide header straddling two farmlands:** yield goes to whichever farmland the header's center is on.
- [ ] **Non-farmland areas** (roads, map areas with ids like 255): nothing recorded and no nonexistent farmland ids in the log.
- [ ] **Hidden farmlands:** yield recorded on a farmland that isn't shown on the farmland screen. The page hides those farmlands, so check whether that data is simply invisible.

## 6. Menu page

- [ ] **First harvest:** the crop appears after reopening the menu.
- [ ] **Crops per field:** with wheat harvested on field 3 and corn on field 4, field 3 lists only wheat and field 4 only corn.
- [ ] **Empty field:** a field with no harvests shows an empty crop list and "No Yield History".
- [ ] **Crop stays selected across fields:** pick corn, then move through fields. Corn stays selected on every field that has it. A field without corn shows its first crop, and corn is selected again on the next field that has it.
- [ ] **Selection highlight:** harvest a crop that sorts alphabetically **before** the selected one, then reopen. The highlighted row still matches the crop shown.
- [ ] **Icons:** mod crop icons show; a crop without an icon shows no broken image.
- [ ] **Language:** switch the game language. Crop names are translated.
- [ ] **Show Owned / Show All Fields** toggle still works.
- [ ] **Graph and year list:**
  - [ ] 1 year
  - [ ] several years
  - [ ] more than 20 years
- [ ] **Year rollover:** harvest across the new year. Yield after the change goes into the new year.

## 7. Compatibility

These mods hook the same game functions. Test with each enabled, and once with only YieldTracker.

- [ ] **Baseline:** only YieldTracker enabled.
- [ ] **FS25_MoistureSystem:** amounts still match the tank (it adjusts yield before it reaches the tank).
- [ ] **FS25_SoilCompaction:** the recorded amount is the reduced amount that reaches the tank.
- [ ] **FS25_precisionFarming:** no errors, amounts match the tank.
- [ ] **FS25_CropRotation:** no errors, amounts match the tank.
- [ ] **FS25_DynamicCombineSpreadWidth:** no errors.
- [ ] **FS25_CutOpenBale:** covered in section 4.

## 8. General

- [ ] **Performance:** no stutter while harvesting, baling or unloading. The hook on placing material on the ground runs often.
- [ ] **Clean log:** after a full session, `log.txt` has no YieldTracker warnings or errors.
- [ ] **Release build:** set `YieldTracker.debug = false` again before release.
