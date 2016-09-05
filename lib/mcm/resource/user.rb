module MCM
  module Resource
    class User < Base
      get :find, '/users/:id'
      get :find_by_name, '/users/byName/:id'
    end
  end
end
