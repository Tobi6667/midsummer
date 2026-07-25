using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance { get; private set; }

    [SerializeField] private AudioMixerGroup musicMixerGroup;
    [SerializeField] private AudioMixerGroup voiceMixerGroup;
    [SerializeField] private AudioMixerGroup sfxMixerGroup;

    [Header("Music")]
    [SerializeField] private AudioSource musicSource;
    [SerializeField] private float musicFadeDuration = 1f;

    [Header("Voice / Lines")]
    [SerializeField] private AudioSource voiceSource;

    [Header("SFX")]
    [SerializeField] private int sfxPoolSize = 8;
    [SerializeField] private AudioSource sfxSourcePrefab; // can be null, we'll create one

    private List<AudioSource> sfxPool;
    private Coroutine musicFadeRoutine;

    private void Awake()
    {

        Instance = this;
        DontDestroyOnLoad(gameObject);

        if (musicSource == null)
            musicSource = CreateSource("MusicSource", musicMixerGroup, loop: true);

        if (voiceSource == null)
            voiceSource = CreateSource("VoiceSource", voiceMixerGroup, loop: false);

        sfxPool = new List<AudioSource>(sfxPoolSize);
        for (int i = 0; i < sfxPoolSize; i++)
        {
            var src = CreateSource($"SfxSource_{i}", sfxMixerGroup, loop: false);
            sfxPool.Add(src);
        }
    }

    private AudioSource CreateSource(string name, AudioMixerGroup group, bool loop)
    {
        var go = new GameObject(name);
        go.transform.SetParent(transform);
        var src = go.AddComponent<AudioSource>();
        src.outputAudioMixerGroup = group;
        src.loop = loop;
        src.playOnAwake = false;
        return src;
    }

    // ---------- MUSIC ----------

    public void PlayMusic(AudioClip clip, bool fade = true, float volume = 1f)
    {
        if (clip == null) return;

        if (musicFadeRoutine != null)
            StopCoroutine(musicFadeRoutine);

        if (fade)
            musicFadeRoutine = StartCoroutine(CrossfadeMusic(clip, volume));
        else
        {
            musicSource.clip = clip;
            musicSource.volume = volume;
            musicSource.Play();
        }
    }

    public void StopMusic(bool fade = true)
    {
        if (musicFadeRoutine != null)
            StopCoroutine(musicFadeRoutine);

        if (fade)
            musicFadeRoutine = StartCoroutine(FadeOutAndStop());
        else
            musicSource.Stop();
    }

    private IEnumerator CrossfadeMusic(AudioClip newClip, float targetVolume)
    {
        float startVolume = musicSource.volume;
        float t = 0f;

        // fade out current
        if (musicSource.isPlaying)
        {
            while (t < musicFadeDuration)
            {
                t += Time.deltaTime;
                musicSource.volume = Mathf.Lerp(startVolume, 0f, t / musicFadeDuration);
                yield return null;
            }
        }

        musicSource.clip = newClip;
        musicSource.volume = 0f;
        musicSource.Play();

        // fade in new
        t = 0f;
        while (t < musicFadeDuration)
        {
            t += Time.deltaTime;
            musicSource.volume = Mathf.Lerp(0f, targetVolume, t / musicFadeDuration);
            yield return null;
        }
        musicSource.volume = targetVolume;
    }

    private IEnumerator FadeOutAndStop()
    {
        float startVolume = musicSource.volume;
        float t = 0f;
        while (t < musicFadeDuration)
        {
            t += Time.deltaTime;
            musicSource.volume = Mathf.Lerp(startVolume, 0f, t / musicFadeDuration);
            yield return null;
        }
        musicSource.Stop();
        musicSource.volume = startVolume;
    }

    // ---------- VOICE / LINES ----------

    public void PlayVoiceLine(AudioClip clip, float volume = 1f)
    {
        if (clip == null) return;
        voiceSource.Stop();
        voiceSource.clip = clip;
        voiceSource.volume = volume;
        voiceSource.Play();
    }

    public void StopVoiceLine() => voiceSource.Stop();

    public bool IsVoiceLinePlaying => voiceSource.isPlaying;

    // ---------- SFX ----------

    public void PlaySfx(AudioClip clip, float volume = 1f, float pitch = 1f)
    {
        if (clip == null) return;
        var src = GetFreeSfxSource();
        src.clip = clip;
        src.volume = volume;
        src.pitch = pitch;
        src.Play();
    }

    public void PlaySfxAtPoint(AudioClip clip, Vector3 position, float volume = 1f)
    {
        if (clip == null) return;
        AudioSource.PlayClipAtPoint(clip, position, volume);
    }

    private AudioSource GetFreeSfxSource()
    {
        foreach (var src in sfxPool)
        {
            if (!src.isPlaying) return src;
        }
        // all busy: steal the first one
        return sfxPool[0];
    }

    // ---------- VOLUME (optional, mixer-based) ----------

    public void SetMusicVolume(float volume01) => musicSource.volume = volume01;
    public void SetVoiceVolume(float volume01) => voiceSource.volume = volume01;
    public void SetSfxVolume(float volume01)
    {
        foreach (var src in sfxPool) src.volume = volume01;
    }
}