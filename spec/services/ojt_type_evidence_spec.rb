require "rails_helper"

RSpec.describe OJTTypeEvidence do
  def audit(text, single: true)
    described_class.new(text: text, single_occupation: single).call
  end

  it "reads the selected approach rather than the first or last option" do
    result = audit("☐ Time-based    ☒ Competency-based    ☐ Hybrid")

    expect(result.ojt_type).to eq "competency"
    expect(result.evidence.first).to include(page: 1, kind: "checked_choice", quote: "☐ Time-based    ☒ Competency-based    ☐ Hybrid")
  end

  it "supports hybrid and checked tick boxes" do
    expect(audit("☐ Time-based ☐ Competency-based ☑ Hybrid").ojt_type).to eq "hybrid"
  end

  it "ignores generic definitions and competency template headings" do
    text = "The time-based approach measures hours; competency-based and hybrid approaches are also available.\fThis is a time-based apprenticeship standard.\nCompetency-based Occupation: Please describe competencies."
    result = audit(text)

    expect(result.ojt_type).to eq "time"
    expect(result.evidence).to eq [{ojt_type: "time", page: 2, kind: "explicit_statement", quote: "This is a time-based apprenticeship standard."}]
  end

  it "recognizes explicit mastery completion when checkbox graphics disappear" do
    text = "Time-based Competency-based Hybrid\nThe term of the occupation is based on the apprentice’s demonstration of the mastery of\ncompetencies as specified in these standards (approximately 1 year), supplemented by the\nrequired hours of related instruction."

    expect(audit(text).ojt_type).to eq "competency"
    expect(audit(text).evidence.first[:kind]).to eq "completion_requirement"
  end

  it "leaves conflicting source selections for review" do
    result = audit("☒ Time-based ☐ Competency-based ☐ Hybrid\f☐ Time-based ☒ Competency-based ☐ Hybrid")

    expect(result.ojt_type).to be_nil
    expect(result.reason).to include "Conflicting"
    expect(result.evidence.map { |e| e[:page] }).to eq [1, 2]
  end

  it "does not infer an approach from a code suffix, hours, or tasks" do
    expect(audit("RAPIDS 2031CB\n2,000 hours\nCompetencies: Inspect equipment").ojt_type).to be_nil
  end

  it "does not classify mastery plus required OJL time as competency-based" do
    text = "The term of the occupation is based on the apprentice's demonstration of competencies and requires at least 2,000 hours of OJL."

    expect(audit(text).ojt_type).to be_nil
  end

  it "does not attribute another occupation's approach in a shared source" do
    result = audit("☒ Time-based ☐ Competency-based ☐ Hybrid", single: false)

    expect(result.ojt_type).to be_nil
    expect(result.reason).to include "boundaries"
  end

  it "does not treat unrelated checked training methods as approach selections" do
    expect(audit("Method of instruction:\n☒ Hybrid\n☒ Community college; ☒ Other training").ojt_type).to be_nil
  end

  it "reads a choice split across lines beneath an approach heading" do
    expect(audit("APPRENTICESHIP APPROACH\n☐ Time-based\n☒ Competency-based\n☐ Hybrid").ojt_type).to eq "competency"
  end

  it "preserves PDF::Reader fallback page numbers" do
    result = audit("--- Page 1 ---\nCover\n\n--- Page 2 ---\n☒ Time-based ☐ Competency-based ☐ Hybrid")

    expect(result.evidence.first[:page]).to eq 2
  end

  it "recognizes an explicitly labeled training approach in a bulletin" do
    result = audit("Type of Training: Hybrid")

    expect(result.ojt_type).to eq "hybrid"
    expect(result.evidence.first[:kind]).to eq "explicit_label"
  end

  it "does not treat a label listing all approaches as a selection" do
    expect(audit("Type of Training: Time-based, competency-based or hybrid").ojt_type).to be_nil
  end
end
