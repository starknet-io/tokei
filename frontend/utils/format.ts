
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

export function timeAgo(date: Date): string {
    const now = new Date();
    const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);
  
    if (diffInSeconds < 60) {
      return `${diffInSeconds} seconds ago`;
    } else if (diffInSeconds < 3600) {
      const minutes = Math.floor(diffInSeconds / 60);
      return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
    } else if (diffInSeconds < 86400) {
      const hours = Math.floor(diffInSeconds / 3600);
      return `${hours} hour${hours > 1 ? 's' : ''} ago`;
    } else {
      const days = Math.floor(diffInSeconds / 86400);
      return `${days} day${days > 1 ? 's' : ''} ago`;
    }
  }
export const formatDateTime=(dateTime: Date): string=> {
    const options: Intl.DateTimeFormatOptions = {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
    };
  
    return dateTime.toLocaleString(undefined, options);
  }
  
