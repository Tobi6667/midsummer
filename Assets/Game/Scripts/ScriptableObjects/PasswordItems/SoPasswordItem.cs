using UnityEngine;

[CreateAssetMenu(menuName = "Password/Item")]
public class SoPasswordItem : ScriptableObject
{
    [SerializeField] private Sprite _hintIcon;
    public Sprite HintIcon => _hintIcon;
    public int Id;
    public Sprite Icon;
}
