(function($){
    Sandbox = function(name) {
        this.name = name;
//        this.util = Core.getPlugin('util');
        this.subscribe = function(type, fn) {
            return Core.addToSubscribers(type, fn, name);
        };
        this.unsubscribe = function(type, fn) {
            return Core.removeFromSubscribers(type, fn, name);
        };
        this.publish = function(type, data) {
            // console.log(type, data);
            return Core.fireEvent(type, data);
        };
        this.getPlugin = function(plugin_name) {
            return Core.getPlugin(plugin_name);
        };
        this.log = function(message) {
            return Core.log(message);
        };
//        this.assert = function(desc, test) {
//            return this.util.assert(desc, test);
//        };
//        this.queue = function(fn, context, time) {
//            return this.util.queue.add(fn, context, time);
//        };
//        this.clearQueue = function() {
//            return this.util.queue.clear();
//        };
    };
    window.Core = (function() {
        var addErrorLogging, extensions, isFunction, modules, plugins;
        modules = {};
        plugins = {};
        extensions = {};
        isFunction = function(obj) {
            return typeof obj === 'function';
        };
        addErrorLogging = function(object) {
            var method, name, _i, _len;
            for (_i = 0, _len = object.length; _i < _len; _i++) {
                name = object[_i];
                method = object[name];
                if (isFunction(method)) {
                    object[name] = (function(name, method) {
                        return function() {
                            try {
                                return method.apply(this, arguments);
                            } catch (err) {
                                return this.log(name + "(): " + err.message);
                            }
                        };
                    })(name, method);
                }
            }
            return object;
        };
        return addErrorLogging({
            init: function() {
                this.initializePlugins();
                return this.startModules();
            },
            loadModule: function(module_name, fn) {
                modules[module_name] = {
                    constructor: fn,
                    instance: null,
                    subscribers: {}
                };
                return fn;
            },
            loadExtension: function(extension_name, fn) {
                return extensions[extension_name] = fn;
            },
            loadPlugin: function(plugin_name, fn) {
                var plugin;
                plugin = fn(new Sandbox(name));
                addErrorLogging(plugin);
                return plugins[plugin_name] = plugin;
            },
            initializePlugins: function() {
                var name, plugin, _results;
                _results = [];
                for (name in plugins) {
                    plugin = plugins[name];
                    if (isFunction(plugin.init)) {
                        _results.push(plugin.init());
                    } else {
                        _results.push(void 0);
                    }
                }
                return _results;
            },
            startModules: function() {
                var module, name, sandbox;
                for (name in modules) {
                    module = modules[name];
                    sandbox = new Sandbox(name);
                    module.sandbox = sandbox;
                    module.instance = module.constructor(sandbox);
                    this.includeExtensions(module);
                    addErrorLogging(module.instance);
                    if (isFunction(module.instance.init)) {
                        module.instance.init();
                    }
                    if (isFunction(module.instance.onReady)) {
                        module.instance.onReady();
                    }
                }
            },
            includeExtensions: function(module) {
                var extension, extension_instance, module_extensions, name, owner_module;
                if (module.instance.extensions) {
                    false;
                }
                module_extensions = {};
                if (modules[module]) {
                    owner_module = modules[module];
                }
                for (name in extensions) {
                    extension = extensions[name];
                    extension_instance = extension(module.sandbox, owner_module);
                    addErrorLogging(extension_instance);
                    if (isFunction(extension_instance.init)) {
                        extension_instance.init();
                    }
                    module_extensions[name] = extension_instance;
                }
                return module.instance.extensions = module_extensions;
            },
            addToSubscribers: function(name, fn, module_name) {
                var module;
                module = modules[module_name];
                if (module) {
                    return module.subscribers[name] = fn;
                }
            },
            removeFromSubscribers: function (name, fn, module_name) {
                var module;
                module = modules[module_name];
                if (module && module.subscribers[name] === fn) {
                    delete module.subscribers[name];
                }
            },
            fireEvent: function(name) {
                var data, list, module, module_name;
                data = Array.prototype.slice.call(arguments, 1);
                for (module_name in modules) {
                    module = modules[module_name];
                    list = module.subscribers;
                    if (list[name] && isFunction(list[name])) {
                        list[name].apply(this, data);
                    }
                }
            },
            getModule: function(module_name) {
                return modules[module_name];
            },
            getPlugin: function(plugin_name) {
                return plugins[plugin_name];
            },
            log: function(message) {
                if (window.console && typeof window.console === 'object') {
                    return console.warn(message);
                }
            }
        });
    }).call(this);
})(jQuery);