varying highp vec4 DestinationColor;

varying highp vec2 TexCoordOut; // New
uniform sampler2D Texture; // New

void main(void) {
    gl_FragColor = DestinationColor * texture2D(Texture, TexCoordOut); // New
}