module MCM
  module Resource
   class Root < Base
     get :find, '', has_many: [:groups], has_one: [:user]
   end
  end
end
