module MCM
  module Resource
   class Group < Base
     get :list, '/groups'
     get :find, '/groups/:id'
   end
  end
end
