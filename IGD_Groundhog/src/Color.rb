module IGD
	module Groundhog
    
        # Module meant to handle color transformation between one colorspace to another.      
		module Color
            
            @CIE_x_r	=	0.640
            @CIE_y_r	=	0.330
            @CIE_x_g	=	0.290
            @CIE_y_g	=	0.600
            @CIE_x_b	=	0.150
            @CIE_y_b	=	0.060
            @CIE_x_w	=	1.0/3.0
            @CIE_y_w	=	1.0/3.0

            @CIE_D	=	(	@CIE_x_r*(@CIE_y_g - @CIE_y_b) + \
            				@CIE_x_g*(@CIE_y_b - @CIE_y_r) + \
            				@CIE_x_b*(@CIE_y_r - @CIE_y_g)	)
            @CIE_C_rD =	( (1.0/@CIE_y_w) * \
            				( @CIE_x_w*(@CIE_y_g - @CIE_y_b) - \
            				  @CIE_y_w*(@CIE_x_g - @CIE_x_b) + \
            				  @CIE_x_g*@CIE_y_b - @CIE_x_b*@CIE_y_g	) )
            @CIE_C_gD =	( (1.0/@CIE_y_w) * \
            				( @CIE_x_w*(@CIE_y_b - @CIE_y_r) - \
            				  @CIE_y_w*(@CIE_x_b - @CIE_x_r) - \
            				  @CIE_x_r*@CIE_y_b + @CIE_x_b*@CIE_y_r	) )
            @CIE_C_bD =	( (1.0/@CIE_y_w) * \
            				( @CIE_x_w*(@CIE_y_r - @CIE_y_g) - \
            				  @CIE_y_w*(@CIE_x_r - @CIE_x_g) + \
            				  @CIE_x_r*@CIE_y_g - @CIE_x_g*@CIE_y_r	) )


            @xyz2rgbmat = [
                [(@CIE_y_g - @CIE_y_b - @CIE_x_b*@CIE_y_g + @CIE_y_b*@CIE_x_g)/@CIE_C_rD,
                 (@CIE_x_b - @CIE_x_g - @CIE_x_b*@CIE_y_g + @CIE_x_g*@CIE_y_b)/@CIE_C_rD,
                 (@CIE_x_g*@CIE_y_b - @CIE_x_b*@CIE_y_g)/@CIE_C_rD],

                [(@CIE_y_b - @CIE_y_r - @CIE_y_b*@CIE_x_r + @CIE_y_r*@CIE_x_b)/@CIE_C_gD,
                 (@CIE_x_r - @CIE_x_b - @CIE_x_r*@CIE_y_b + @CIE_x_b*@CIE_y_r)/@CIE_C_gD,
                 (@CIE_x_b*@CIE_y_r - @CIE_x_r*@CIE_y_b)/@CIE_C_gD],

                [(@CIE_y_r - @CIE_y_g - @CIE_y_r*@CIE_x_g + @CIE_y_g*@CIE_x_r)/@CIE_C_bD,
                 (@CIE_x_g - @CIE_x_r - @CIE_x_g*@CIE_y_r + @CIE_x_r*@CIE_y_g)/@CIE_C_bD,
                 (@CIE_x_r*@CIE_y_g - @CIE_x_g*@CIE_y_r)/@CIE_C_bD]
             ]


             # Transforms a color from one colorspace to another
             # @author German Molina based on Radiance's code
             # @param c [<float>] A color. An array of three floats
             # @param mat [<float>] A 3x3 float matrix that Transforms from one color to another
             # @return [<float>] The color in another colorspace
            def self.colortrans(c,mat)
                cout = []
            	cout[0] = mat[0][0]*c[0] + mat[0][1]*c[1] + mat[0][2]*c[2];
            	cout[1] = mat[1][0]*c[0] + mat[1][1]*c[1] + mat[1][2]*c[2];
            	cout[2] = mat[2][0]*c[0] + mat[2][1]*c[1] + mat[2][2]*c[2];
                return cout
            end

            # Transforms an xyz color into RGB
            # @author German Molina based on Radiance's code
            # @param xyz [<float>] a xyz color. An array of 3 floats
            # @return [<float>] The color in RGB space
            def self.cie2rgb(xyz)
                return colortrans(xyz,@xyz2rgbmat)
            end

        end
    end
end
