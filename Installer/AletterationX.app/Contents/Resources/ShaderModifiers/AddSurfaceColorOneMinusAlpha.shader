uniform vec3 mu_SurfaceColor;
uniform vec3 mu_DiffuseTintColor;

_surface.diffuse = vec4((mu_SurfaceColor*(1.0-_surface.diffuse.a))+((_surface.diffuse.rgb*mu_DiffuseTintColor)*_surface.diffuse.a), 1.0);
_surface.ambient = _surface.diffuse;