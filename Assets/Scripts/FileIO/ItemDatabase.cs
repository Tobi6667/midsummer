using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

[CreateAssetMenu]
public class ItemDatabase : ScriptableObject
{
	[SerializeField] Item[] items;

	public Item GetItem(string itemID)
	{
		foreach (Item item in items)
		{
			if (item.ID == itemID)
			{
				return item;
			}
		}
		return null;
	}

	#if UNITY_EDITOR
	private void OnEnable()
	{
		EditorApplication.projectChanged -= OnProjectChanged;
		EditorApplication.projectChanged += OnProjectChanged;
	}

	private void OnDisable()
	{
		EditorApplication.projectChanged -= OnProjectChanged;
	}

	private void OnProjectChanged()
	{
		items = FindAssetsByType<Item>();
	}

	public static T[] FindAssetsByType<T>() where T : Object
	{
		string type = typeof(T).ToString().Replace("UnityEngine.", "");

		string[] guids = AssetDatabase.FindAssets("t:" + type);

		T[] assets = new T[guids.Length];

		for (int i = 0; i < guids.Length; i++)
		{
			string assetPath = AssetDatabase.GUIDToAssetPath(guids[i]);
			assets[i] = AssetDatabase.LoadAssetAtPath<T>(assetPath);
		}
		return assets;
	}
	#endif
}
