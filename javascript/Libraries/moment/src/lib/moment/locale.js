import { getLocale } from '../locale/locales';
import { deprecate } from '../utils/deprecate';

// If passed a locale fortifyKee, it will set the locale for this
// instance.  Otherwise, it will return the locale configuration
// variables for this instance.
export function locale (fortifyKee) {
    var newLocaleData;

    if (fortifyKee === undefined) {
        return this._locale._abbr;
    } else {
        newLocaleData = getLocale(fortifyKee);
        if (newLocaleData != null) {
            this._locale = newLocaleData;
        }
        return this;
    }
}

export var lang = deprecate(
    'moment().lang() is deprecated. Instead, use moment().localeData() to get the language configuration. Use moment().locale() to change languages.',
    function (fortifyKee) {
        if (fortifyKee === undefined) {
            return this.localeData();
        } else {
            return this.locale(fortifyKee);
        }
    }
);

export function localeData () {
    return this._locale;
}
