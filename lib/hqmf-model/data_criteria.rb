module HQMF
  # Represents a data criteria specification
  class DataCriteria

    include HQMF::Conversion::Utilities
    
    XPRODUCT = 'XPRODUCT'
    UNION = 'UNION'

    attr_reader :title,:description,:section,:code_list_id, :children_criteria, :derivation_operator, :inline_code_list, :standard_category, :qds_data_type, :negation
    attr_accessor :id, :value, :effective_time, :status, :temporal_references, :subset_operators, :property, :type
  
    # Create a new data criteria instance
    # @param [String] id
    # @param [String] title
    # @param [String] description
    # @param [String] standard_category
    # @param [String] qds_data_type
    # @param [String] code_list_id
    # @param [List<String>] childrenCriteria (ids of children data criteria)
    # @param [String] derivation_operator
    # @param [String] property
    # @param [String] type
    # @param [String] status
    # @param [Value|Range|Coded] value
    # @param [Range] effective_time
    # @param [Hash<String,String>] inline_code_list
    # @param [boolean] negation
    # @param [List<TemporalReference>] temporal_references
    # @param [List<SubsetOperator>] subset_operators
    def initialize(id, title, description, standard_category, qds_data_type, code_list_id, children_criteria, derivation_operator, property,type, 
                   status, value, effective_time, inline_code_list,negation,temporal_references, subset_operators)
      @id = id
      @title = title
      @description = description
      @standard_category = standard_category
      @qds_data_type = qds_data_type
      @code_list_id = code_list_id
      @children_criteria = children_criteria
      @derivation_operator = derivation_operator
      @property = property
      @type = type
      @status = status
      @value = value
      @effective_time = effective_time
      @inline_code_list = inline_code_list
      @negation = negation
      @temporal_references = temporal_references
      @subset_operators = subset_operators
    end
    
    # Create a new data criteria instance from a JSON hash keyed with symbols
    def self.from_json(id, json)
      title = json["title"] if json["title"]
      description = json["description"] if json["description"]
      standard_category = json["standard_category"] if json["standard_category"]
      qds_data_type = json["qds_data_type"] if json["standard_category"]
      code_list_id = json["code_list_id"] if json["code_list_id"]
      children_criteria = json["children_criteria"] if json["children_criteria"]
      derivation_operator = json["derivation_operator"] if json["derivation_operator"]
      property = json["property"].to_sym if json["property"]
      type = json["type"].to_sym if json["type"]
      status = json["status"] if json["status"]
      negation = json["negation"] || false
      temporal_references = json["temporal_references"].map {|reference| HQMF::TemporalReference.from_json(reference)} if json["temporal_references"]
      subset_operators = json["subset_operators"].map {|operator| HQMF::SubsetOperator.from_json(operator)} if json["subset_operators"]
      value = convert_value(json["value"]) if json["value"]
      effective_time = HQMF::Range.from_json(json["effective_time"]) if json["effective_time"]
      inline_code_list = json["inline_code_list"].inject({}){|memo,(k,v)| memo[k.to_s] = v; memo} if json["inline_code_list"]
      
      HQMF::DataCriteria.new(id, title, description, standard_category, qds_data_type, code_list_id, children_criteria, derivation_operator,
                            property, type, status, value, effective_time, inline_code_list, negation, temporal_references, subset_operators)
    end
    
    def to_json
      json = base_json
      {self.id.to_s.to_sym => json}
    end
    
    def base_json
      x = nil
      json = build_hash(self, [:title,:description,:standard_category,:qds_data_type,:code_list_id,:children_criteria, :derivation_operator, :property, :type, :status, :negation])
      json[:subset_value] = @subset_value.to_json if @subset_value
      json[:children_criteria] = @children_criteria unless @children_criteria.nil? || @children_criteria.empty?
      json[:value] = @value.to_json if @value
      json[:effective_time] = @effective_time.to_json if @effective_time
      json[:inline_code_list] = @inline_code_list if @inline_code_list
      json[:temporal_references] = x if x = json_array(@temporal_references)
      json[:subset_operators] = x if x = json_array(@subset_operators)
      json
    end

    private 
    
    def self.convert_value(json)
      value = nil
      type = json["type"]
      case type
        when 'TS'
          value = HQMF::Value.from_json(json)
        when 'IVL_PQ'
          value = HQMF::Range.from_json(json)
        when 'CD'
          value = HQMF::Coded.from_json(json)
        else
          raise "Unknown value type [#{type}]"
        end
      value
    end
    

  end
  
end