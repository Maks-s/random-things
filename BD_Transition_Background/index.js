module.exports = (Plugin, Api, Vendor, Deps) => {

    const { Events, Logger, DOM, CssUtils } = Api;

    return class extends Plugin {

        get onUnload() {
            return this.onStop;
        }

        async changeBackground(index, bg) {
            const file = this.images[index];
            const data = await file.readBuffer();
            const mime = await file.filetype();

            bg.style.background = `url('data:image/${mime[0][1]};base64,${data[0][1].toString('base64')}') center/cover no-repeat`;
        }

        async updateBackground() {
            if (this.focus && document.hasFocus())
                return;

            if (this.random)
                this.index = Math.floor( Math.random() * this.images.length );
            else if (++this.index >= this.images.length)
                this.index = 0;

            const lastBg = document.getElementsByClassName('transitioning-background')[0];
            const newBg = DOM.createElement('div', 'transitioning-background').prependTo(document.body);

            await this.changeBackground(this.index, newBg);

            if (lastBg) {
                lastBg.classList.add(`tb-${this.effect}`);
                console.log(this.effect)
                setTimeout(() => {
                    if (lastBg && lastBg.parentElement)
                        lastBg.parentElement.removeChild(lastBg);

                }, this.speed * 1000);
            }
        }

        async updateTransition(speed) {
            CssUtils.injectStyle('transition', `
                .transitioning-background {
                    transition-duration: ${speed}s;
                    transition-timing-function: ease-in-out;
                    transition-property: transform, opacity;
                }
            `);
        }

        async toggleTransparency(yes) {
            if (yes) {
                CssUtils.injectStyle('transparency', `
                    .theme-dark .chat-3bRxxu form, .theme-dark .members-1998pB, .theme-dark .markup-2BOw-j code, .theme-dark .markup-2BOw-j code.inline.theme-dark .members-1998pB, .theme-dark .messagesWrapper-3lZDfY, .theme-dark .title-3qD0b-, .container-PNkimc, .channels-Ie2l6A, .theme-dark .chat-3bRxxu, .theme-dark .content-yTz4x3, .theme-dark .layer-3QrUeG, .theme-dark .layers-3iHuyZ, .container-2lgZY8, .theme-dark .guildsWrapper-5TJh6A {
                        background: transparent;
                    }
                    
                    .appMount-3VJmYg {
                        background: rgba(0,0,0,0.6);
                    }
                    
                    .theme-dark .markup-2BOw-j code, .theme-dark .markup-2BOw-j code.inline, .theme-dark .markup-2BOw-j pre {
                        background: rgba(0,0,0,0.2);
                        border: 1px solid #440;
                    }
                    
                    ::-webkit-scrollbar-track-piece {
                        background: rgba(0,0,0,0.2) !important;
                        border: none !important;
                    }
                    ::-webkit-scrollbar-thumb {
                        background: rgba(255, 255, 255, 0.15) !important;
                        border: none !important;
                    }
                    ::-webkit-scrollbar-thumb:hover {
                        background: #7289da !important;
                    }
                `);
            } else {
                CssUtils.deleteStyle('transparency');
            }
        }

        async onStart() {
            this.images = this.settings.getSetting('images').items
                .map( value => value.settings[0].settings[0] );

            if (!this.images.length)
                throw {message: 'No background images set'};
            
            this.delay = this.settings.get('delay');
            this.speed = this.settings.get('speed');
            this.effect = this.settings.get('effect');
            this.random = this.settings.get('random');
            this.focus = this.settings.get('focus');

            this.settings.on('setting-updated', async event => {
                switch (event.setting_id) {
                case 'speed':
                    this.updateTransition(event.value);
                    break;

                case 'delay':
                    clearInterval(this.update);
                    this.update = setInterval(this.updateBackground, event.value * 1000);
                    break;
                
                case 'images':
                    console.log('wat')
                    this.images = event.value
                        .map( value => value.settings[0].settings[0] );
                    
                    if (!this.images.length) {
                        Plugin.stopPlugin(this);
                    }
                    return;
                
                case 'transparency':
                    this.toggleTransparency(event.value);
                    return;

                default:
                    break;
                }

                this[event.setting_id] = event.value;
            });

            CssUtils.injectStyle('default', `
                .transitioning-background {
                    background-size: cover;
                    background-position: center;
                    width: 100%;
                    height: 100%;
                    position: fixed;
                    pointer-events: none;
                }

                #app-mount {
                    background: none !important;
                }

                .tb-fade { opacity: 0; }
                .tb-fade-zoom { transform: scale(5); opacity: 0; }
                .tb-slide-left { transform: translateX(-100%); }
                .tb-slide-right { transform: translateX(100%); }
                .tb-slide-up { transform: translateY(-100%); }
                .tb-slide-down { transform: translateY(100%); }
                .tb-shrink { transform: scale(0); }
                .tb-rotate-horizontal { transform: rotateX(90deg); }
                .tb-rotate-vertical { transform: rotateY(90deg); }
            `);

            if (this.settings.get('transparency'))
                this.toggleTransparency(true);

            const bg = DOM.createElement('div', 'transitioning-background').prependTo(document.body);

            await this.updateTransition(this.speed);
            await this.changeBackground(0, bg);

            this.index = 0;
            this.update = setInterval(() => {
                this.updateBackground();
            }, this.delay * 1000);

            return true;
        }

        async onStop() {
            CssUtils.deleteAllStyles();

            if (this.update)
                clearInterval(this.update);

            const backgrounds = document.getElementsByClassName('transitioning-background');
            while (backgrounds.length) // when removeChild is used, the entry is removed from backgrounds
                if (backgrounds[0] && backgrounds[0].parentElement)
                    backgrounds[0].parentElement.removeChild(backgrounds[0]);

            return true;
        }
    }
}
