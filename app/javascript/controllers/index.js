// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from './application';

import Code from './code';
import ClipboardCopy from './clipboard-copy';
import Darkmode from './darkmode';
import TableOfContents from './table-of-contents';

import PwaInstallation from './pwa/installation';
import PwaWebPushSubscription from './pwa/web-push-subscription';
import PwaWebPushDemo from './pwa/web-push-demo';

application.register('code', Code);
application.register('clipboard-copy', ClipboardCopy);
application.register('darkmode', Darkmode);
application.register('table-of-contents', TableOfContents);
application.register('pwa-installation', PwaInstallation);
application.register('pwa-web-push-subscription', PwaWebPushSubscription);
application.register('pwa-web-push-demo', PwaWebPushDemo);
