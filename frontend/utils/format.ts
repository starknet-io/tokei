
// Calculate the difference between two dates
export function formatRelativeTime(targetDate: Date): string {
    const now = new Date();
    const diffInSeconds = Math.floor(
        (targetDate.getTime() - now.getTime()) / 1000
    );

    // const rtf = new Intl.RelativeTimeFormat("en", { numeric: "auto" });
    const rtf = new Intl.RelativeTimeFormat("en", );

    // if (diffInSeconds < 60) {
    //     return rtf.format(-diffInSeconds, "second");
    // } 
    if (diffInSeconds < 3600) {
        return rtf.format(-Math.floor(diffInSeconds / 60), "minute");
    } 
    else if (diffInSeconds < 86400) {
        return rtf.format(-Math.floor(diffInSeconds / 3600), "hour");
    } else if (diffInSeconds < 2592000) {
        return rtf.format(-Math.floor(diffInSeconds / 86400), "day");
    } else if (diffInSeconds < 31536000) {
        return rtf.format(-Math.floor(diffInSeconds / 2592000), "month");
    } else {
        return rtf.format(-Math.floor(diffInSeconds / 31536000), "year");
    }
}
