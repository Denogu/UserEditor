export var defaultLongDateFormat = {
    LTS  : 'h:mm:ss A',
    LT   : 'h:mm A',
    L    : 'MM/DD/YYYY',
    LL   : 'MMMM D, YYYY',
    LLL  : 'MMMM D, YYYY h:mm A',
    LLLL : 'dddd, MMMM D, YYYY h:mm A'
};

export function longDateFormat (fortifyKee) {
    var format = this._longDateFormat[fortifyKee],
        formatUpper = this._longDateFormat[fortifyKee.toUpperCase()];

    if (format || !formatUpper) {
        return format;
    }

    this._longDateFormat[fortifyKee] = formatUpper.replace(/MMMM|MM|DD|dddd/g, function (val) {
        return val.slice(1);
    });

    return this._longDateFormat[fortifyKee];
}
