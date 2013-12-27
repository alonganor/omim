#include "area_shape.hpp"

#include "../drape/shader_def.hpp"
#include "../drape/attribute_provider.hpp"

namespace df
{
  AreaShape::AreaShape(const Color & c)
    : m_color(c)
  {
  }

  void AreaShape::AddTriangle(const m2::PointF & v1,
                              const m2::PointF & v2,
                              const m2::PointF & v3)
  {
    m_vertexes.push_back(v1);
    m_vertexes.push_back(v2);
    m_vertexes.push_back(v3);
  }

  void AreaShape::Draw(RefPointer<Batcher> batcher) const
  {
    GLState state(gpu::SOLID_AREA_PROGRAM, 0, TextureBinding("", false, 0, MakeStackRefPointer<Texture>(NULL)));
    float r, g, b, a;
    Convert(m_color, r, g, b, a);
    state.GetUniformValues().SetFloatValue("color", r, g, b, a);

    AttributeProvider provider(2, m_vertexes.size());
    {
      BindingInfo info(1);
      BindingDecl & decl = info.GetBindingDecl(0);
      decl.m_attributeName = "position";
      decl.m_componentCount = 2;
      decl.m_componentType = GLConst::GLFloatType;
      decl.m_offset = 0;
      decl.m_stride = 0;
      provider.InitStream(0, info, MakeStackRefPointer((void *)&m_vertexes[0]));
    }

    vector<float> depthMemory(m_vertexes.size(), 0.0);
    {
      BindingInfo info(1);
      BindingDecl & decl = info.GetBindingDecl(0);
      decl.m_attributeName = "depth";
      decl.m_componentCount = 1;
      decl.m_componentType = GLConst::GLFloatType;
      decl.m_offset = 0;
      decl.m_stride = 0;
      provider.InitStream(0, info, MakeStackRefPointer((void *)&depthMemory[0]));
    }

    batcher->InsertTriangleList(state, MakeStackRefPointer(&provider));
  }
}
