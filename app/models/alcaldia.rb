class Alcaldia < ApplicationRecord
  belongs_to :state

  has_many :users, dependent: :restrict_with_error
  has_many :reports, dependent: :restrict_with_error
  has_many :categories, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :state_id }

  def has_boundary?
    boundary.present?
  end

  def contains_point?(lat, lng)
    return true unless has_boundary?

    result = self.class.connection.select_value(
      ActiveRecord::Base.sanitize_sql_array([
        "SELECT ST_Contains(boundary, ST_SetSRID(ST_MakePoint(?, ?), 4326)) FROM alcaldias WHERE id = ?",
        lng.to_f, lat.to_f, id
      ])
    )
    ActiveModel::Type::Boolean.new.cast(result)
  end

  def boundary_as_geojson
    return nil unless has_boundary?

    self.class.connection.select_value(
      ActiveRecord::Base.sanitize_sql_array([
        "SELECT ST_AsGeoJSON(boundary) FROM alcaldias WHERE id = ?", id
      ])
    )
  end

  def boundary_from_geojson(geojson_string)
    return if geojson_string.blank?

    self.class.connection.execute(
      ActiveRecord::Base.sanitize_sql_array([
        "UPDATE alcaldias SET boundary = ST_SetSRID(ST_GeomFromGeoJSON(?), 4326) WHERE id = ?",
        geojson_string, id
      ])
    )
    reload
  end
end
