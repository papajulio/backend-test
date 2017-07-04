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

      @mapsViewsPercentageQuery = "
        SELECT G.name AS group, U.name AS user, SUM(mapviews) AS views,
          ROUND((SUM(mapviews)*100)::numeric/(MIN(total_views)),2) || '%' AS percent_of_group_views
        FROM groups AS G
        JOIN groups_users AS GU ON GU.group_id = G.id
        JOIN users AS U ON GU.user_id = U.id
        JOIN maps AS M ON U.id = M.user_id
        JOIN (SELECT GU.group_id, SUM(mapviews) AS total_views
              FROM groups_users AS GU
              JOIN maps AS M ON GU.user_id = M.user_id
              GROUP BY GU.group_id) AS totals ON TOTALS.group_id = G.id
        GROUP BY G.name, U.name
        ORDER BY G.name, views DESC"
      @mapsViewsPercentage = ActiveRecord::Base.connection.exec_query(@mapsViewsPercentageQuery)
  end
end
