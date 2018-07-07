class Average
    include Mongoid::Document
    field :ha
    field :ht
    field :tm
    field :lm
    field :ps
    field :unix
    field :nlecturas
    store_in collection: 'average'
end