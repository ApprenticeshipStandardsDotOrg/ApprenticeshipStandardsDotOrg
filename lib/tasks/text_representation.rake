namespace :text_representation do
  task import_missing: :environment do
    DataImport.all.find_each do |di|
      puts di.id
      next unless di.import
      begin
        di.to_text
      rescue PDF::Reader::MalformedPDFError
        next
      end
    end
  end
end


keywords = ["LLM", "NLP", "Machine Intelligence", "Machine Learning", "Large Language Model", "Generative AI", "Chatbot", "Deep Learning", "Cognitive Computing", "Automated Reasoning", "Application programming interface", "Predictive Analytics", "Sentiment Analysis", "Intelligent Automation", "Transformer Model", "Smart Technology", "Prompting", "Model Bias", "Meta Prompt", "System Prompt", "Prompt Engineering", "Quantum Computing", "Data-Driven Intelligence", "Data Mining", "Structured Data", "Unstructured Data", "Training Data", "Algorithmic Intelligence", "Algorithm", "Image Recognition", "Embedded Intelligence", "Neural Network", "RAG (Retrieval-Augmented Generation)", "Robotic Process Automation", "Natural Language Processing", "Anthropomorphism", "Agents", "Token", "Context Window", "Emergent Behavior", "Multimodal Model", "Data Scientist", "Machine Learning Engineer", "AI Researcher", "Deep Learning Specialist", "Natural Language Processing (NLP) Engineer", "Robotics Engineer", "Computer Vision Engineer", "AI Ethics Consultant", "Business Intelligence Analyst", "AI Product Manager", "AI Data Annotator", "Machine Learning Data Curator"]
