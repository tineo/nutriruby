class Lectura
    include Mongoid::Document
    field :ha
    field :ht
    field :tm
    field :lm
    field :ps
    field :unix
    field :purl
    store_in collection: 'huerto'
end