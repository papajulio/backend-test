class HomeController < ApplicationController
  def index
      @users = User.joins("LEFT JOIN groups_users ON user_id = users.id LEFT JOIN groups ON group_id = groups.id")
      @users = @users.select("users.name, users.created_at, count(groups.name) AS num_groups, string_agg(groups.name, ', ') AS groups_names")
      @users = @users.group("users.name, users.created_at")


      @mapsViewsQuery = "
        SELECT G.name AS group_name, U.name AS user, SUM(mapviews) AS views
        FROM groups AS G
        JOIN groups_users AS GU ON group_id = G.id
        JOIN users AS U ON GU.user_id = U.id
        JOIN maps AS M ON U.id = M.user_id
        GROUP BY G.name, U.name
        ORDER BY G.name, views DESC"
      @mapsViews = ActiveRecord::Base.connection.exec_query(@mapsViewsQuery)
  end
end
