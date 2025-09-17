// Fragment Shader لتحويل YUV إلى RGB
shader_type canvas_item;

// التكسشرات الثلاث للـ YUV
uniform sampler2D y_texture : filter_linear;
uniform sampler2D u_texture : filter_linear; 
uniform sampler2D v_texture : filter_linear;

// معاملات التحويل (يمكن ضبطها حسب نوع الفيديو)
uniform bool full_color_range = false;
uniform int color_profile = 1; // 1 = BT.709, 2 = BT.601, etc.

// مصفوفات التحويل لمعايير مختلفة
const mat3 BT709_MATRIX = mat3(
    vec3(1.0, 0.0, 1.5748),
    vec3(1.0, -0.1873, -0.4681),
    vec3(1.0, 1.8556, 0.0)
);

const mat3 BT601_MATRIX = mat3(
    vec3(1.0, 0.0, 1.4020),
    vec3(1.0, -0.3441, -0.7141),
    vec3(1.0, 1.7720, 0.0)
);

const mat3 BT2020_MATRIX = mat3(
    vec3(1.0, 0.0, 1.7166),
    vec3(1.0, -0.1881, -0.6504),
    vec3(1.0, 2.1414, 0.0)
);

vec3 yuv_to_rgb(vec3 yuv, mat3 conversion_matrix) {
    // تطبيق التحويل
    vec3 rgb = conversion_matrix * yuv;
    
    // قص القيم للنطاق الصحيح
    return clamp(rgb, 0.0, 1.0);
}

void fragment() {
    // أخذ إحداثيات التكسل
    vec2 uv = UV;
    
    // أخذ قيم YUV من التكسشرات المختلفة
    float y = texture(y_texture, uv).r;
    float u = texture(u_texture, uv).r;  
    float v = texture(v_texture, uv).r;
    
    // تحويل النطاق حسب نوع الفيديو
    if (full_color_range) {
        // Full range (0-255)
        y = y;
        u = u - 0.5;
        v = v - 0.5;
    } else {
        // Limited range (16-235 for Y, 16-240 for UV)
        y = (y * 255.0 - 16.0) / 219.0;
        u = (u * 255.0 - 128.0) / 224.0;
        v = (v * 255.0 - 128.0) / 224.0;
    }
    
    vec3 yuv = vec3(y, u, v);
    vec3 rgb;
    
    // اختيار مصفوفة التحويل حسب المعيار
    if (color_profile == 1) {
        rgb = yuv_to_rgb(yuv, BT709_MATRIX); // HD/FHD/4K عادة
    } else if (color_profile == 2) {
        rgb = yuv_to_rgb(yuv, BT601_MATRIX); // SD فيديوهات قديمة
    } else if (color_profile == 9 || color_profile == 10) {
        rgb = yuv_to_rgb(yuv, BT2020_MATRIX); // 4K HDR
    } else {
        // Default إلى BT.709
        rgb = yuv_to_rgb(yuv, BT709_MATRIX);
    }
    
    COLOR = vec4(rgb, 1.0);
}