using System;
using System.Collections.Generic;

public static class StoryEventBus
{
    private static readonly Dictionary<Type, Delegate> _listeners = new();

    public static void Subscribe<T>(Action<T> listener)
        where T : IGameEvent
    {
        if (_listeners.TryGetValue(typeof(T), out var del))
            _listeners[typeof(T)] = Delegate.Combine(del, listener);
        else
            _listeners[typeof(T)] = listener;
    }


    public static void Unsubscribe<T>(Action<T> listener)
        where T : IGameEvent
    {
        if (!_listeners.TryGetValue(typeof(T), out var del))
            return;

        var current = Delegate.Remove(del, listener);

        if (current == null)
            _listeners.Remove(typeof(T));
        else
            _listeners[typeof(T)] = current;
    }


    public static void Publish<T>(T e)
        where T : IGameEvent
    {
        if (_listeners.TryGetValue(typeof(T), out var del))
        {
            ((Action<T>)del)?.Invoke(e);
        }
    }
}