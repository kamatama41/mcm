module MCM
  module Resource
   class Group < Base
     get :list, '/groups'
     get :find, '/groups/:id'
     get :find_by_name, '/groups/byName/:id'
   end
  end
end
