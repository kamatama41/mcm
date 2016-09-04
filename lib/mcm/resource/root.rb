module MCM
  module Resource
   class Root < Base
     get :find, '', has_many: {groups: Group}
   end
  end
end
