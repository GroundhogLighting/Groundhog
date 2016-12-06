module IGD
  module Groundhog

    # This module is in charge of triangulating and refining all  Workplane meshes... far from perfect, but works.
    module Triangle

      # Transforms a set of points and polygons into an array of
      # @author German Molina
      # @param points [Array] an array of SketchUp::3DPoint
      # @param polygons [Array] a Nx3 array of SketchUp::3DPoint, where each row is a polygon indicating which triangle in 'points' form the triangle
      # @return [Array] A 2D array, where each row is one triangle formed by 3 SketchUp::3DPoint
      def self.to_triangles(points, polygons)
        ret = []
        polygons.each do |polygon|
          v0 = points[polygon[0].abs-1]
          v1 = points[polygon[1].abs-1]
          v2 = points[polygon[2].abs-1]
          ret.push([v0,v1,v2])
        end
        return ret
      end

      # Calculates the area of a triangle
      # @author German Molina
      # @param a [SketchUp::Point3d] Side a of triangle
      # @param c [SketchUp::Point3d] Side b of triangle
      # @param b [SketchUp::Point3d] Side c of triangle
      # @return [Numeric] The area of the triangle
      def self.get_area(a,b,c)
        return Math.sqrt((c+b+a)*((c+b+a)/2-a)*((c+b+a)/2-b)*((c+b+a)/2-c))/Math.sqrt(2)
      end

      # Refines a triangle... It does this by just spliting each edge by half, forming 4 triangles.
      #
      # It is expected that the input to this are just Delaunay-compliant triangles
      # @author German Molina
      # @param triangles [Array] an array of Nx3 SketchUp::3DPoint
      # @return [Array] an array of Nx3 SketchUp::3DPoint
      def self.refine_triangles(triangles)
        final_triangles = []
        desired_pixel_area = Config.desired_pixel_area/0.00064516 #in square inches

        #first we transform them into Delaunay-compliant triangles (as much as we can)
        triangles.each do |triangle|
          a = triangle[0].distance(triangle[1])
          b = triangle[1].distance(triangle[2])
          c = triangle[2].distance(triangle[0])
          area = get_area(a,b,c)

          if area < desired_pixel_area  then
            final_triangles.push(triangle)
            next
          end

          #now, add 4 new triangles
          p01 = Geom::Point3d.new([ (triangle[0].x+triangle[1].x)/2, (triangle[0].y+triangle[1].y)/2,(triangle[0].z+triangle[1].z)/2 ])
          p12 = Geom::Point3d.new([ (triangle[1].x+triangle[2].x)/2, (triangle[1].y+triangle[2].y)/2,(triangle[1].z+triangle[2].z)/2 ])
          p20 = Geom::Point3d.new([ (triangle[2].x+triangle[0].x)/2, (triangle[2].y+triangle[0].y)/2,(triangle[2].z+triangle[0].z)/2 ])

          final_triangles.push([triangle[0], p01, p20])
          final_triangles.push([triangle[1], p12, p01])
          final_triangles.push([triangle[2], p20, p12])
          final_triangles.push([p01, p12, p20])
        end
        return final_triangles
      end

      # From a set of triangles it makes just Delaunay-compliant triangles
      # @author German Molina
      # @param triangles [Array] an array of Nx3 SketchUp::3DPoint
      # @return [Array] an array of Nx3 SketchUp::3DPoint
      # @note This might be a horrible algorithm... I made id up from nothing
      def self.get_delaunay_triangles(triangles)
        final_triangles = []
        ratio_threshold = 1
        min_area = 0.005/0.00064516 #in square inches
        #first we transform them into Delaunay-compliant triangles
        triangles.each do |triangle|
          a = triangle[0].distance(triangle[1])
          b = triangle[1].distance(triangle[2])
          c = triangle[2].distance(triangle[0])

          sqrt = (a+b+c)*(b+c-a)*(c+a-b)*(a+b-c)
          next if sqrt < 1e-4 #ignore triangles that are too long

          circumradius = a*b*c/Math.sqrt(sqrt)
          shortest_edge = [a,b,c].min
          ratio = circumradius/shortest_edge

          #if it is a good triangle or too small: store and next
          if ratio < ratio_threshold or get_area(a,b,c) < min_area  then
            final_triangles.push(triangle)
            next
          end

          #otherwise, we get the pivot vertex and triangulate
          pivot = triangle[0]
          farthest = triangle[1]
          other = triangle[2]
          largest_edge = [a,b,c].max
          if shortest_edge == a then
            pivot = triangle[2]
            if largest_edge == c then
              farthest = triangle[0]
              other = triangle[1]
            else
              farthest = triangle[1]
              other = triangle[0]
            end
          elsif shortest_edge ==  b then
            if largest_edge == c then
              farthest = triangle[2]
              other = triangle[1]
            else
              farthest = triangle[1]
              other = triangle[2]
            end
          elsif shortest_edge == c then
            pivot = triangle[1]
            if largest_edge == b then
              farthest = triangle[2]
              other = triangle[0]
            else
              farthest = triangle[0]
              other = triangle[2]
            end
          end

          #now that we have identified everything, we subdivide (add the 3 new triangles)
          largest_mid = Geom::Point3d.new([ (pivot.x+farthest.x)/2, (pivot.y+farthest.y)/2,(pivot.z+farthest.z)/2 ])
          other_mid = Geom::Point3d.new([ (pivot.x+other.x)/2, (pivot.y+other.y)/2,(pivot.z+other.z)/2 ])

          final_triangles.push([pivot, largest_mid, other_mid])
          final_triangles.push([other, other_mid, largest_mid])
          final_triangles.push([farthest, other, largest_mid])

        end
        return final_triangles
      end

      # Calculates the center of a triangle, as just the average of all the
      #   points
      # @author German Molina
      # @param triangle [Array] an array of 3 SketchUp::3DPoint
      # @return [SketchUp::Point3d] The normal of the triangle
      def self.get_center(triangle)
        return Geom::Point3d.new([(triangle[0].x+triangle[1].x+triangle[2].x)/3, (triangle[0].y+triangle[1].y+triangle[2].y)/3,(triangle[0].z+triangle[1].z+triangle[2].z)/3])
      end

      # Triangulates and refines a workplane
      # @author German Molina
      # @param points [Array] an array of SketchUp::3DPoint
      # @param polygons [Array] a Nx3 array of SketchUp::3DPoint, where each row is a polygon indicating which triangle in 'points' form the triangle
      # @return [Array] A 2D array, where each row is one triangle formed by 3 SketchUp::3DPoint
      def self.triangulate(points,polygons)

        triangles = to_triangles(points,polygons)
        #first, get delaunay-compliant triangles
        old_n_triangles = -99
        did_something = true
        while did_something do
          triangles = self.get_delaunay_triangles(triangles)
          did_something = (old_n_triangles != triangles.length)
          old_n_triangles = triangles.length
        end

        #Second, refine the mesh
        old_n_triangles = -99
        did_something = true
        while did_something do
          triangles = self.refine_triangles(triangles)
          did_something = (old_n_triangles != triangles.length)
          old_n_triangles = triangles.length
        end

        return triangles

      end


    end #end module
  end
end
