using UnityEngine;

public class HighlightComponent : MonoBehaviour, IHighlight
{
    [SerializeField] private Renderer _renderer;
    [SerializeField] private Color _highlightColor = Color.yellow;

    private MaterialPropertyBlock _block;
    private static readonly int EmissionColor = Shader.PropertyToID("_EmissionColor");

    private void Awake() => _block = new MaterialPropertyBlock();

    public void SetHighlighted(bool highlighted)
    {
        _renderer.GetPropertyBlock(_block);
        _block.SetColor(EmissionColor, highlighted ? _highlightColor : Color.black);
        _renderer.SetPropertyBlock(_block);
    }


}
