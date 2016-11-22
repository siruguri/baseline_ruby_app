class RunRecord
  include Mongoid::Document

  field :run_tag, type: String
  field :urls, type: String
  field :run_at, type: DateTime
end
